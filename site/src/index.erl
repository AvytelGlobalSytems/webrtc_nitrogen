%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to Nitrogen".

body() ->
	Peerid = integer_to_list(crypto:rand_uniform(0,1000000000000000000)),
	wf:wire(#js_fun{function=init_webrtc, args=[Peerid]}),
	wf:continue(connect, fun() -> timer:sleep(1000), offer_queue:send_offer(Peerid) end, infinity),
	[
	 	#panel{id=waiting, text="Waiting for a connection"},
		#video{id=my_video, autoplay=true},
		#video{id=other_video, autoplay=true}
	].

continue(connect, {CR, Peerid}) ->
	error_logger:info_msg("New PEer: ~p",[Peerid]),
	wf:remove(waiting),
	case CR of
		caller ->
			wf:wire(#js_fun{function=webrtc_call, args=[Peerid]});
		_ ->
			ok
	end.
	%wf:wire(page, page, #api{name=send_rtc, tag=Pid}),
