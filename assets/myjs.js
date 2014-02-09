
var state = {
	current : "",
	data : Qt.createQmlObject('import bb.cascades 1.2; QtObject {signal updated() }', Qt.application, 'PlayState'),
	update : function(state) {
		HTTPRequest("GET", "engine", serverNotification, state);
	},
	change : function(cmd) {
		console.debug("callCommand : " + cmd);
		HTTPRequest("GET", "command", null, cmd);
		state.update("play");
	},
	serverNotification: function(response) {
		state.current = JSON.parse(response);
		state.data.updated();
		
		//long poll request to listen for additional events
		state.update(state.current.state);
	}
	// listener: setup to listen to playState.updated, and call update with state.current.state. Clean out of the callback function
};

var browselist = {
	current : "",
	data : Qt.createQmlObject('import bb.cascades 1.2; QtObject {signal updated() }', Qt.application, 'DataState'),
	getDataNext : function(index) {
		if (browselist.current[index].directory) {
			browselist.getdata(browselist.current[index].directory);
		} else {
			//not a directory, so must be a file. or something went horribly wrong...play automatically
			browselist.playlistAdd(index, "addplay");
		}
	},
	getDataPrevious : function() {
		//var semaphore = false;	
		var str = browselist.current[0].directory ? browselist.current[0].directory : browselist.current[0].file;
		if (!(str === appRoot.activeTab.browseRoot)) {
			str = str.substring(0, str.lastIndexOf("/"));
			if (!(str === appRoot.activeTab.browseRoot)) {
				browselist.getdata(str.substring(0, str.lastIndexOf("/")));
			}
		}
		/*
		if (!(str.substring(0, str.lastIndexOf("/")) === appRoot.activeTab.browseRoot)) {
			//semaphore = true;
			str = str.substring(0,str.lastIndexOf("/"));
			if (!(str.substring(0, str.lastIndexOf("/")) === appRoot.activeTab.browseRoot)) {
				str = str.substring(0,str.lastIndexOf("/"));
			}

			//if (semaphore) {
				browselist.getdata(str);
			//}
		} 
		*/
	},
	getDataRoot : function() {
		if (browselist.current) {
			var str = browselist.current[0].directory ? browselist.current[0].directory : browselist.current[0].file;
			if (!(str.substring(0, str.lastIndexOf("/")) === appRoot.activeTab.browseRoot)) {
				browselist.getdata(appRoot.activeTab.browseRoot);
			}
		} else {
			browselist.getdata(appRoot.activeTab.browseRoot);
		}
	},
	getdata : function(path) {
		MyJS.HTTPRequest("POST", "db", browseDataNotification, "filepath", path);
	},
	playlistAdd : function(index, action) {
		MyJS.HTTPRequest("POST", "db", onPlaylistAdd , action, browselist.current[index].directory ? browselist.current[index].directory : browselist.current[index].file);
	},
	onDataLoadComplete : function(data) {
        browselist.current = JSON.parse(data);
        //if in the nas directory, then go 1 deeper
        if ((browselist.current.length == 1) && (browselist.current[0].directory === "NAS/nas")) {
        	appRoot.activeTab.browseRoot = "NAS/nas";
            browselist.getDataNext(0);
        }  else {
        	browselist.data.updated();
        }
    }
};

//work around, because it didn't seem to want to call the real callback directly
function browseDataNotification(response) {
	browselist.onDataLoadComplete(response);
};
function onPlaylistAdd (response) {
	console.debug("added");
}
function serverNotification(response) {
	state.serverNotification(response);
};
function capitalise(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}
/* type: GET/POST
 * url: db/engine/command
 * callback
 * qsParam: value after the directory name
 * post: any post values...tbd encoding, etc
 * 
 * Return JSON (sometimes empty
 * *****Needs enhancements to return a JSON object, with data/errors/etc
 */
function HTTPRequest(type, action, callback, qsParam, postString) {
	//for now. Needs to be read from a store at some point.
	var url = "http://192.168.0.102/";
	if (action=="engine") {
		url+="_player_engine.php?state=";
	}	else if (action=="db"||action=="command") {
		url+=action+"/?cmd=";
	} else {
		//error
		console.debug("HTTP Request Error: " + action);
	}
	url+=qsParam;
	
	var request = new XMLHttpRequest();
	request.onreadystatechange=function() {
        // Need to wait for the DONE state or you'll get errors
        if(request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                console.debug("HTTP Response : " + request.responseText);
                if (typeof callback == "function" ) {
                	callback(request.responseText);
                } else {
                	console.debug("Info : callback param not a valid function :" + callback);
                }
                return
            }
            else {
                // This is very handy for finding out why your web service won't talk to you
                console.debug("Status: " + request.status + ", Status Text: " + request.statusText);
            }
        } 
    };
    // Make sure whatever you post is URI encoded
    if (!(type=="GET" || type == "POST")) {
    	//throw an error
    	console.debug("Error: invalid param value of type. POST/GET only! : " + type);
    }
    
    request.open(type, url, true); // only async supported
    
    if (type == "POST") {
    	request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    	request.send("path=" + encodeURIComponent(postString));
    } else {
    	request.send();
    }
    
    console.debug("HTTP Request: " + url);
}