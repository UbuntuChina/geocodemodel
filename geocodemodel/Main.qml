import QtQuick 2.4
import Ubuntu.Components 1.3
import QtLocation 5.3
import QtPositioning 5.2

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "geocodemodel.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    Plugin {
        id: plugin
        name: "osm"
    }

    ListModel {
        id: mymodel
    }

    PositionSource {
        id: me
        active: true
        updateInterval: 1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        onPositionChanged: {
            console.log("lat: " + position.coordinate.latitude + " longitude: " +
                        position.coordinate.longitude);
            console.log(position.coordinate)
            console.log("mapzoom level: " + map.zoomLevel)
            map.coordinate = position.coordinate
        }

        onSourceErrorChanged: {
            console.log("Source error: " + sourceError);
        }
    }

    GeocodeModel {
        id: geocodeModel
        plugin: plugin
        autoUpdate: false

        onStatusChanged: {
            mymodel.clear()
            console.log("onStatusChanged")
            if ( status == GeocodeModel.Ready ) {
                var count = geocodeModel.count
                console.log("count: " + geocodeModel.count)
                for ( var i = 0; i < count; i ++ ) {
                    var location = geocodeModel.get(i);
                    mymodel.append( {"location": location})
                }
            }
        }

        onLocationsChanged: {
            console.log("onStatusChanged")
        }

        Component.onCompleted: {
            query = "中国 北京 朝阳 望京"
            update()
        }
    }

    Page {
        id: page
        header: standardHeader

        PageHeader {
            id: standardHeader
            visible: page.header === standardHeader
            title: "Geocoding"
            trailingActionBar.actions: [
                Action {
                    iconName: "edit"
                    text: "Edit"
                    onTriggered: page.header = editHeader
                }
            ]
        }

        PageHeader {
            id: editHeader
            visible: page.header === editHeader
            leadingActionBar.actions: [
                Action {
                    iconName: "back"
                    text: "Back"
                    onTriggered: {
                        page.header = standardHeader
                    }
                }
            ]
            contents: TextField {
                id: input
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                placeholderText: "input words .."
                text: "中国 北京 朝阳 望京"

                onAccepted: {
                    geocodeModel.query = text
                    geocodeModel.update()
                }
            }
        }

        Item  {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: page.header.bottom
            }

            Column {
                anchors.fill: parent

                ListView {
                    id: listview
                    clip: true
                    width: parent.width
                    height: parent.height/3
                    opacity: 0.5
                    model: mymodel
                    delegate: Item {
                        id: delegate
                        width: listview.width
                        height: layout.childrenRect.height + units.gu(0.5)

                        Column {
                            id: layout
                            width: parent.width

                            Text {
                                width: parent.width
                                text: location.address.text
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: "(" + location.coordinate.longitude + ", " +
                                      location.coordinate.latitude + ")"
                            }

                            Rectangle {
                                width: parent.width
                                height: units.gu(0.1)
                                color: "green"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("it is clicked")
                                map.coordinate = location.coordinate
                                // We do not need the position info any more
                                me.active = false
                            }
                        }
                    }
                }

                Map {
                    id: map
                    width: parent.width
                    height: parent.height*2/3
                    property var coordinate

                    plugin : Plugin {
                        name: "osm"
                    }

                    zoomLevel: 14
                    center: coordinate

                    MapCircle {
                        center: map.coordinate
                        radius: units.gu(3)
                        color: "red"
                    }

                    Component.onCompleted: {
                        zoomLevel = 14
                    }
                }
            }
        }

        Component.onCompleted: {
            console.log("geocodeModel limit: " + geocodeModel.limit)
        }
    }
}

