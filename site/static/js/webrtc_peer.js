navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
var conn;
var peer;

function init_webrtc(my_peerid) {
	peer = new Peer(my_peerid, {key: "webrtctest", host: "webrtctest.com", port: 9000, debug: 3});

	peer.on('call', function(call) {
		navigator.getUserMedia({video: true, auto: false}, function(stream) {
			call.answer(stream);
			call.on('stream', function(remoteStream) {
				add_stream_to_tag(remoteStream, 'other_video');
				add_stream_to_tag(stream, 'my_video');
			});
		}, function(err) {
			console.log(err);
		});
	});

}

function webrtc_call(remote_peerid) {
	navigator.getUserMedia({video: true, audio: false}, function(stream) {
	  console.log(remote_peerid);
	  var call = peer.call(remote_peerid, stream);
      console.log(call);
	  call.on('stream', function(remoteStream) {
		add_stream_to_tag(remoteStream, 'other_video');
		add_stream_to_tag(stream, 'my_video');
	  });
	}, function(err) {
	  console.log('Failed to get local stream' ,err);
	});
}


function add_stream_to_tag(stream, elementid) {
	obj(elementid).src=window.URL.createObjectURL(stream);
}

