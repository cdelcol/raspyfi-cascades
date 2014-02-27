function param(o) {
	/**supported types
	 * simple object
	 * 
	 * return: URL-encoded string 
	 */
	var encoded="";
	for (var property in o) {
		encoded+= property + '=' + encodeURIComponent(o[property]);
	};
	return encoded;
}
function ajax(o) {
	//set some defaults
	o.type = o.type || "GET";
	o.contentType = o.contentType || "application/x-www-form-urlencoded";
	o.data = param(o.data);
	
	/**required params
	 * url
	 * 
	 **supported params
	 * url
	 * type
	 * debug
	 * success
	 * error
	 * data (only for POST)
	 */
	
	var r = new XMLHttpRequest();
	r.onreadystatechange=function() {
        if(r.readyState === XMLHttpRequest.DONE) {
            if (r.status === 200) {
            	if (o.debug) console.debug("HTTP Response : " + r.responseText);
                
                if (typeof o.success == "function" ) {
                	o.success(r.responseText, r.status, r);
                } else {
                	if (o.debug) console.log("Info : 'success' option not a valid function :" + o.success);
                };
            } else {
                if (o.debug) console.log("Status: " + r.status + ", Status Text: " + r.statusText);
                if (typeof o.error == "function") {
                	o.error(r, r.status);
                };
            };
        } ;
    };

    // only async supported
    r.open(o.type, o.url, true);
    r.setRequestHeader("Content-type", o.contentType);
    
    if (o.type == "POST") {
    	if (o.debug) console.debug("HTTP Request - type:" + o.type, "| url:" + o.url, "| data:" + o.data);
    	r.send(o.data);
    } else {
    	if (o.debug) console.debug("HTTP Request - type:" + o.type, "| url:" + o.url);
    	r.send();
    }
    
    
}