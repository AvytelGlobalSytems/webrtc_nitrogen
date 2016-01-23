%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to Nitrogen".

body() ->
	wf:wire(#api{name=sendoffer}),
	[
		"<script>var conn = new RTCPeerConnection(null);
		
		conn.onaddstream = function(event) {
			var tag = obj('my_video');
			attachMediaString(tag, event.stream);
		},

		function accept_conn(desc_str) {
			var desc = JSON.parse(desc_str);
			console.log(desc);
			conn.setRemoteDescription(new RTCSessionDescription(desc), function() {
				if(conn.remoteDescription.type == 'offer') {
					conn.addStream(stream);
					conn.createAnswer(function(desc) {
						conn.setLocalDescription(desc, function() {
							JSON.stringify(
				}
			})
		}
		</script>",
		#video{id=my_video, autoplay=true},
		#button{text="Start", postback=start}
	].

	
start_stream() ->
	wf:wire("getUserMedia({video: true, audio: true}, function(stream) {
		conn.addStream(stream);
		conn.createOffer(function(desc) {
			conn.setLocalDescription(desc, function() {
				page.sendoffer(JSON.stringify(desc));
			})
		})			
	}, function(event) {
		alert('something went wrong')
	})").

api_event(sendoffer, _, [Desc]) ->
	gen_server:cast(offer_queue, {offer, Desc, self()}),
	wf:continue(offer, fun() ->
		receive
			{offer, ReceivedDesc} ->
				ReceivedDesc
		end
	end, infinity).

continue(offer, Desc) ->
	wf:wire(#js_fun{function=accept_conn, args=[Desc]}).

event(start) ->
	start_stream().
