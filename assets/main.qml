import bb.cascades 1.2
import "js/app.js" as APP
import "js-common/sub-zepto.js" as Z$


TabbedPane {
    id: appRoot
    Tab {
        title: "Playback"
        imageSource: "asset:///images/ic_speaker.png"
        Page {
            id: pagePlayback
            Container {
                verticalAlignment: VerticalAlignment.Fill

                layout: StackLayout {}

                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1.0
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Top
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0
                    }
                    topMargin: 20.0
                    leftPadding: 10.0
                    rightPadding: 10.0
                    bottomPadding: 50.0

                    Header {
                        title: "Now playing"
                    }
                    Label {
                        id: nowPlayingArtist
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        id: nowPlayingSong
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.color: Color.Cyan
                        textStyle.fontSize: FontSize.XXLarge
                        multiline: true
                        textStyle.textAlign: TextAlign.Center
                    }
                    Label {
                        id: nowPlayingAlbum
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.fontSize: FontSize.Large
                    }
                }
                Container {
                    verticalAlignment: VerticalAlignment.Bottom
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    topMargin: 20.0
                    leftPadding: 10.0
                    rightPadding: 10.0
                    bottomPadding: 50.0

                    Button {
                        imageSource: "asset:///images/ic_speaker_mute.png"
                        onClicked: {
                            if (playbackVolume.value != 0) {
                                APP.state.GUI.volume = Math.floor(playbackVolume.value);
                                APP.state.set("setvol", 0);
                            } else {
                                APP.state.set("setvol", APP.state.GUI.volume);
                            }
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }

                    Slider {
                        id: playbackVolume
                        toValue: 100
                        verticalAlignment: VerticalAlignment.Bottom
                        function changeVolume(v) {
                            APP.state.GUI.volume = APP.state.current.volume;
                            APP.state.set("setvol", Math.floor(v));
                        }
                        onCreationCompleted: {
                            playbackVolume.valueChanged.connect(changeVolume);
                        }
                    }
                    Button {
                        imageSource: "asset:///images/ic_speaker.png"
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                }
                Container {
                    verticalAlignment: VerticalAlignment.Bottom
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    topMargin: 20.0
                    leftPadding: 10.0
                    rightPadding: 10.0
                    bottomPadding: 50.0
                    Button {
                        id: previous
                        imageSource: "asset:///images/ic_previous.png"
                        onClicked: {
                            APP.state.set("previous");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: stop
                        imageSource: "asset:///images/ic_stop.png"
                        onClicked: {
                            APP.state.set("stop");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: playpause
                        imageSource: "asset:///images/ic_play.png"
                        onClicked: {
                            if (APP.state.current.state=="play") {
                                APP.state.set("pause");
                            } else {
                                APP.state.set("play");
                            }
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: next
                        imageSource: "asset:///images/ic_next.png"
                        onClicked: {
                            APP.state.set("next");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                }
            }
            onCreationCompleted: {
                APP.state.data.updated.connect(pagePlayback.statusUpdated);
                APP.state.listenForUpdate("");
            }

            function statusUpdated() {
                console.debug("Status updated...");
                nowPlayingAlbum.text = APP.state.current.currentalbum || "";
                nowPlayingArtist.text = APP.state.current.currentartist || "";
                nowPlayingSong.text = APP.state.current.currentsong || "";
                
                //if we need to change volume: remove binding, set, replace binding
                if (!(Math.floor(playbackVolume.value)==APP.state.current.volume)) {
                    playbackVolume.valueChanged.disconnect(playbackVolume.changeVolume);
                    playbackVolume.value = APP.state.current.volume;
                    playbackVolume.valueChanged.connect(playbackVolume.changeVolume);
                }

                //play/pause button toggle
                if (APP.state.current.state=="pause") {
                    playpause.setImageSource("asset:///images/ic_pause.png");
                } else {
                    playpause.setImageSource("asset:///images/ic_play.png");
                }
            }            
        }

    }
    Tab {
        id: browseNAS
        title: "Network Music"
        delegate: Delegate {
            source: "browseMusic.qml"
        }
        imageSource: "asset:///images/ic_view_list.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        property string browseRoot: "NAS/nas"
    }
    Tab {
        id: browseWEBRADIO
        title: "Web Radio"
        delegate: Delegate {
            source: "browseMusic.qml"
        }
        imageSource: "asset:///images/ic_view_list.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        property string browseRoot: "WEBRADIO"
    }
    attachedObjects: [
        ComponentDefinition {
            id: topMenu
            source: "topMenu.qml"
        }
    ]
    onCreationCompleted: {
        Menu.definition = topMenu.createObject();
    }
}
