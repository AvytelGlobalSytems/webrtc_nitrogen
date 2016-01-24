var _myConnection,
	_myMediaStream;

function _createConnection(onStreamAddedCallback) {
	// Create a new PeerConnection
	var connection = new RTCPeerConnection(null);

	// ICE Candidate Callback
	connection.onicecandidate = function (event) {
		if (event.candidate) {
			page.send_rtc(JSON.stringify({ "candidate": event.candidate }));
		}
	};

	// Negotiation needed callback
	connection.onnegotiationneeded = function () {
		console.log("nogiation needed");
		connection.createOffer(function (desc) {
			console.log("created offer");
			connection.setLocalDescription(desc, function () {
				console.log("sending rtc");
				page.send_rtc(JSON.stringify({ "sdp": connection.localDescription }));
			});
		});
	};

	// Stream handler
	connection.onaddstream = onStreamAddedCallback;

	return connection;
}


function webrtc_message(data) {
	console.log(data);
	var message = JSON.parse(data),
		connection = _myConnection || _createConnection(onAddStream);

	console.log({"received webrtc_message":message});
	if (message.sdp) {
		connection.setRemoteDescription(new RTCSessionDescription(message.sdp), function () {
			if (connection.remoteDescription.type == "offer") {
				console.log('received offer, sending response...');
				connection.createAnswer(function (desc) {
					console.log("Sending answer");
					connection.setLocalDescription(desc, function () {
						console.log("sett local desc and send");
					});
				});
			}
		});
	} else if (message.candidate) {
		console.log('adding ice candidate...');
		connection.addIceCandidate(new RTCIceCandidate(message.candidate));
	}

	_myConnection = connection;
};

function onAddStream(event) {
	console.log('Adding stream id: ' + event.stream.id);

	var newVideoElement = document.createElement('video');
	newVideoElement.className = 'video';
	newVideoElement.src = window.URL.createObjectURL(event.stream);
	newVideoElement.autoplay = 'autoplay';

	document.querySelector('body').appendChild(newVideoElement);
}

function init_webrtc(caller_or_receiver) {
	getUserMedia(
		{
			// Request Permissions
			video: true,
			audio: false
		},
		function (stream) { // succcess callback
			var videoElement = obj('my_video');

			_myMediaStream = stream;
			videoElement.src = window.URL.createObjectURL(_myMediaStream);

			console.log('my stream id: ' + stream.id);
			if(caller_or_receiver=="caller") {
				_myConnection = _createConnection(onAddStream);
				_myConnection.addStream(_myMediaStream);
			}

			//$('#startBtn').removeAttr('disabled');
		},
		function (error) { // error callback
			console.log(error);
			alert(error);
		}
	);

	//$('#startBtn').click(function () {

	//	// done being able to work
	//	$('#startBtn').attr('disabled', 'disabled');
	//});
}
