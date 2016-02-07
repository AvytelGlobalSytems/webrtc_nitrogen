#!/bin/sh

peerjs --key "webrtctest" --sslkey "/etc/letsencrypt/live/webrtc.sigma-star.com/privkey.pem" --sslcert "/etc/letsencrypt/live/webrtc.sigma-star.com/fullchain.pem" --port 9000

