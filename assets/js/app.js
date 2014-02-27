var state = {
	GUI : {
		state : '',
		volume : null
	},
	current : "",
	data : Qt.createQmlObject('import bb.cascades 1.2; QtObject {signal updated() }', Qt.application, 'PlayState'),
	listenForUpdate : function(state) {
        Z$.ajax({
            url: 'http://192.168.0.102/_player_engine.php?state=' + state,
            success: this.updateSuccess,
            error: this.updateSuccess,
            debug: false
        });
	},
	set : function(cmd, value) {
		console.debug("callCommand : " + cmd , value);
		if (cmd==state.current.state) { return; }
		if (cmd=="setvol") {
			if (value==state.current.volume) { return; }
			cmd+=" " + value;
		}
		Z$.ajax({
			url: 'http://192.168.0.102/command/?cmd=' + cmd,
			success: this.changeSuccess,
			debug: false
		});
	},
	changeSuccess: function() {
		console.debug("callCommand completed");
	},
	updateSuccess: function(response) {
		try {
			var o = JSON.parse(response);
			state.current = o;
			state.data.updated();

			//long poll request to listen for additional events
			state.listenForUpdate(state.current.state);
	    }
	    catch (e) {
	    	//error occured. Try with empty state...unknown cause at this point
	    	state.listenForUpdate("");
	    }
	}
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
		var str = browselist.current[0].directory ? browselist.current[0].directory : browselist.current[0].file;
		if (!(str === appRoot.activeTab.browseRoot)) {
			str = str.substring(0, str.lastIndexOf("/"));
			if (!(str === appRoot.activeTab.browseRoot)) {
				browselist.getdata(str.substring(0, str.lastIndexOf("/")));
			}
		}
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
		Z$.ajax({
			url: 'http://192.168.0.102/db/?cmd=filepath',
			type: 'POST',
			data: { 'path' : path },
			success: this.onDataLoadComplete,
			debug: false
		});
	},
	playlistAdd : function(index, action) {
		Z$.ajax({
			url: 'http://192.168.0.102/db/?cmd=' + action,
			type: 'POST',
			data: { 'path' : browselist.current[index].directory ? browselist.current[index].directory : browselist.current[index].file },
			success: this.onPlaylistAdd,
			debug: false
		});
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