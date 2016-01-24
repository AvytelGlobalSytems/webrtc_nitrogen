%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to Nitrogen".

body() ->
	{ok, Pid} = wf:comet(fun() -> receive_loop() end),
	wf:continue(connect, fun() -> offer_queue:send_offer(Pid) end, infinity),
	[
	 	#panel{id=waiting, text="Waiting for a connection"},
		#video{id=my_video, autoplay=true}
	].

receive_loop() ->
	error_logger:info_msg("Comet Pid: ~p",[self()]),
	receive
		{rtc, Msg} ->
			error_logger:info_msg("~p Received: ~p",[self(), Msg]),
			wf:wire(#js_fun{function=webrtc_message, args=[Msg]});
		{alert, Msg} ->
			wf:wire(#alert{text=Msg})
	end,
	wf:flush(),
	receive_loop().
	
api_event(send_rtc, Pid, [Obj]) ->
	error_logger:info_msg("api_event: ~p",[Obj]),
	Pid ! {rtc, Obj}.

continue(connect, {CR, Pid}) ->
	wf:state(pid, Pid),
	wf:remove(waiting),
	wf:wire(page, page, #api{name=send_rtc, tag=Pid}),
	wf:wire(#event{type=timer, delay=1000, actions=#js_fun{function=init_webrtc, args=[CR]}}).
