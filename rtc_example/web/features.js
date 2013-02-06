has_vendor_usermedia = false;
has_vendor_peer = false;
has_vendor_session = false;
has_vendor_ice = false;

function makeAlias(object, name) {
	var fn = object ? object[name]: null;
	if (typeof fn == 'undefined') return function () {}
    return function () {
        return fn.apply(object, arguments);
    }
}

getVendorUserMedia = function() {
	has_vendor_usermedia = true;
		
	if (typeof navigator.webkitGetUserMedia != 'undefined')
    	return navigator.webkitGetUserMedia.bind(navigator);
    	
    if (typeof navigator.mozGetUserMedia != 'undefined')
    	return navigator.mozGetUserMedia.bind(navigator);

	if (typeof navigator.oGetUserMedia != 'undefined')
    	return navigator.oGetUserMedia.bind(navigator);

	if (typeof navigator.msGetUserMedia != 'undefined')
    	return navigator.msGetUserMedia.bind(navigator);
    
    if (typeof navigator.getUserMedia != 'undefined')
		return navigator.getUserMedia.bind(navigator);
};
/*
RTCPeerConnection = function(a, b) {
	has_vendor_peer = true;

	if (typeof webkitRTCPeerConnection != 'undefined')
    	return webkitRTCPeerConnection(a, b);

	if (typeof mozRTCPeerConnection != 'undefined')
    	return mozRTCPeerConnection(a, b);

	if (typeof oRTCPeerConnection != 'undefined')
    	return oRTCPeerConnection(a, b);

	if (typeof msRTCPeerConnection != 'undefined')
    	return msRTCPeerConnection(a, b);
    	
    if (typeof RTCPeerConnection != 'undefined')
		return RTCPeerConnection(a, b);
}

RTCSessionDescription = function(a) {
	has_vendor_session = true;
	
	if (typeof webkitRTCSessionDescription != 'undefined')
		return webkitRTCSessionDescription(a);
		
	if (typeof mozRTCSessionDescription != 'undefined')
		return mozRTCSessionDescription(a);
		
	if (typeof oRTCSessionDescription != 'undefined')
		return oRTCSessionDescription(a);
		
	if (typeof msRTCSessionDescription != 'undefined')
		return msRTCSessionDescription(a);
		
	if (typeof RTCSessionDescription != 'undefined')
		return RTCSessionDescription(a);
}

RTCIceCandidate = function(a) {
	has_vendor_ice = true;
	
	if (typeof webkitRTCIceCandidate != 'undefined')
		return webkitRTCIceCandidate(a);
		
	if (typeof mozRTCIceCandidate != 'undefined')
		return mozRTCIceCandidate(a);
		
	if (typeof oRTCIceCandidate != 'undefined')
		return oRTCIceCandidate(a);
		
	if (typeof msRTCIceCandidate != 'undefined')
		return msRTCIceCandidate(a);
		
	if (typeof RTCIceCandidate != 'undefined')
		return RTCIceCandidate(a);
}
*/
