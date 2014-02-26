/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.2
import "myjs.js" as MyJS


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
                    Header {
                        title: "Now playing"

                    }
                    Label {
                        id: nowPlayingArtist
                        //text: "I am the artist"
                        horizontalAlignment: HorizontalAlignment.Center

                    }
                    Label {
                        id: nowPlayingSong
                        //text: "This is the song name"
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.color: Color.Cyan
                        textStyle.fontSize: FontSize.XXLarge

                    }
                    Label {
                        id: nowPlayingAlbum
                        //text: "Album Name"
                        horizontalAlignment: HorizontalAlignment.Center

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
                            MyJS.state.change("setvol", 0);
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }

                    Slider {
                        id: playbackVolume
                        toValue: 100
                        verticalAlignment: VerticalAlignment.Bottom
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
                            MyJS.state.set("previous");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: stop
                        imageSource: "asset:///images/ic_stop.png"
                        onClicked: {
                            MyJS.state.set("stop");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: playpause
                        imageSource: "asset:///images/ic_play.png"
                        onClicked: {
                            if (MyJS.state.current.state=="play") {
                                MyJS.state.set("pause");
                            } else {
                                MyJS.state.set("play");
                            }
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                    Button {
                        id: next
                        imageSource: "asset:///images/ic_next.png"
                        onClicked: {
                            MyJS.state.set("next");
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                    }
                }
            }
            onCreationCompleted: {
                MyJS.state.data.updated.connect(pagePlayback.statusUpdated);
                MyJS.state.listenForUpdate("");
            }

            function statusUpdated() {
                console.debug("Status updated...");
                nowPlayingAlbum.text = MyJS.state.current.currentalbum || "";
                nowPlayingArtist.text = MyJS.state.current.currentartist || "";
                nowPlayingSong.text = MyJS.state.current.currentsong || "";
                
                //if we need to change volume: remove binding, set, replace binding
                if (!(Math.floor(playbackVolume.value)==MyJS.state.current.volume)) {
                    playbackVolume.valueChanged.disconnect();
                    playbackVolume.value = MyJS.state.current.volume;
                    playbackVolume.valueChanged.connect(function(v){
                            MyJS.state.set("setvol", Math.floor(v));
                    });
                }
                //play/pause button toggle
                if (MyJS.state.current.state=="pause") {
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
