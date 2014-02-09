import bb.cascades 1.2
import "myjs.js" as MyJS

Page {
    id: pageBrowseMusic
    
    actions: [
        ActionItem {
            id: back
            title: "Back"
            imageSource: "asset:///images/ic_previous.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                MyJS.browselist.getDataPrevious();
            }
        },
        ActionItem {
	        id: home
	        title: "Root"
	        imageSource: "asset:///images/ic_home.png"
	        ActionBar.placement: ActionBarPlacement.OnBar
	        onTriggered: {
	            MyJS.browselist.getDataRoot();
	        }
        }
    ]
    Container {
        
        Header {
            title: "Browse for tunes"
        }
                
        ListView {
            id: browseListView
            dataModel: ArrayDataModel {
                id: dbListData
            }
            onTriggered: {
                console.debug(indexPath);
                MyJS.browselist.getDataNext(indexPath);
            }
            contextActions: [
                ActionSet {
                    ActionItem {
                        title: "Add"
                        onTriggered: {
                            MyJS.browselist.playlistAdd(browseListView.selected(), "add");
                        }
                        imageSource: "asset:///images/ic_add.png"
                    }
                    ActionItem {
                        title: "Add and play"
                        onTriggered: {
                            MyJS.browselist.playlistAdd(browseListView.selected(), "addplay");
                        }
                        imageSource: "asset:///images/ic_play.png"
                    }
                    ActionItem {
                        title: "Add, replace and play"
                        onTriggered: {
                            MyJS.browselist.playlistAdd(browseListView.selected(), "addreplaceplay");
                        }
                        imageSource: "asset:///images/ic_open.png"
                    }
                
                }
            ]
        }
 
        onCreationCompleted: {
            MyJS.browselist.data.updated.connect(function(){
                dbListData.clear();
                MyJS.browselist.current.forEach(function(value) {
                    function format(value) {
                        if (value.directory) {
                        	return value.directory.split('/').pop();
                        } else {
                            //get the filename
                            var str = value.file.split('/').pop()
                            //remove the extension
                            str = str.substring(0,str.lastIndexOf("."));
                            //filename = filename.replace(/.[^.]+$/,'');
                            //remove number at the beginning
                            str = str.substr(str.indexOf(" ") + 1, str.length);
                            return str;
                            
                        }
                        
                    }
                    dbListData.append(format(value));
                        //dbListData.append(value.directory ? value.directory.split('/').pop() : value.file.split('/').pop());
                        console.debug(value.directory ? value.directory : value.file);
                });
            });
            
            MyJS.browselist.getDataRoot();
        }
    }
}