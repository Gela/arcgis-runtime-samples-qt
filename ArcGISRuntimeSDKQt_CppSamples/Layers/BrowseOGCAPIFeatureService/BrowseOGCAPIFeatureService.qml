// [WriteFile Name=BrowseOGCAPIFeatureService, Category=Layers]
// [Legal]
// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.12
import QtQuick.Controls 2.12
import Esri.Samples 1.0
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

Item {   
    // Declare the C++ instance which creates the map etc. and supply the view
    BrowseOGCAPIFeatureServiceSample {
        id: model
        mapView: view
    }

    // add a mapView component
    MapView {
        id: view
        anchors.fill: parent

        // Add the OGC feature service UI element
        Control {
            id: uiControl
            anchors {
                right: view.right
                top: view.top
                margins: 10
            }
            padding: 10
            background: Rectangle {
                color: "white"
                border.color: "black"
            }
            contentItem: GridLayout {
                columns: 2
                Label {
                    id: instructionLabel
                    text: "Load the service, then select a layer for display"
                    font.bold: true
                    verticalAlignment: "AlignVCenter"
                    horizontalAlignment: "AlignHCenter"
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                }
                TextField {
                    id: serviceURLBox
                    text: model.featureServiceUrl
                    Layout.fillWidth: true
                    selectByMouse: true
                }
                Button {
                    id: connectButton
                    text: "Load service"
                    enabled: !model.serviceOrFeatureLoading
                    onClicked: model.loadService(serviceURLBox.text);

                }
                ComboBox {
                    id: featureList
                    model: model.featureCollectionList
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Button {
                    id: loadLayerButton
                    text: "Load selected layer"
                    enabled: !model.serviceOrFeatureLoading
                    onClicked: model.loadFeatureCollection(featureList.currentIndex);
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                }
            }
        }

        // Pop-up error message box
        MessageDialog {
            id: errorMessageBox
            title: "Error message!"
            text: model.errorMessage
            icon: StandardIcon.Warning
            visible: model.errorMessage === "" ? false : true
            onAccepted: model.errorMessage = "";
        }
    }
}
