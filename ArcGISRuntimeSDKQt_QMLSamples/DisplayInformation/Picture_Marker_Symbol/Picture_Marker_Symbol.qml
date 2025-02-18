// [WriteFile Name=Picture_Marker_Symbol, Category=DisplayInformation]
// [Legal]
// Copyright 2016 Esri.

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

import QtQuick 2.6
import Esri.ArcGISExtras 1.1
import Esri.ArcGISRuntime 100.12

Rectangle {
    clip: true
    width: 800
    height: 600

    readonly property url dataPath: System.userHomePath + "/ArcGIS/Runtime/Data"

    ViewpointExtent {
        id: startingVP

        extent: Envelope {
            xMin: -229100
            xMax: -223300
            yMin: 6550700
            yMax: 6552100
            spatialReference: SpatialReference { wkid: 3857 }
        }
    }

    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            Basemap {
                initStyle: Enums.BasemapStyleArcGISTopographic
            }

            initialViewpoint: startingVP
        }

        GraphicsOverlay {

            // create Campsite Symbol from URL
            Graphic {

                Point {
                    x: -228835
                    y: 6550763
                    spatialReference: SpatialReference { wkid: 3857 }
                }

                PictureMarkerSymbol {
                    url: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Recreation/FeatureServer/0/images/e82f744ebb069bb35b234b3fea46deae"
                    width: 38.0
                    height: 38.0
                }
            }

            // create blue symbol from local resource
            Graphic {

                Point {
                    x: -223560
                    y: 6552021
                    spatialReference: SpatialReference { wkid: 3857 }
                }

                PictureMarkerSymbol {
                    url: "qrc:/Samples/DisplayInformation/Picture_Marker_Symbol/blue_symbol.png"
                    width: 80.0
                    height: 80.0
                }
            }

            // create orange symbol from file path
            Graphic {

                Point {
                    x: -226773
                    y: 6550477
                    spatialReference: SpatialReference { wkid: 3857 }
                }

                PictureMarkerSymbol {
                    url: dataPath + "/symbol/orange_symbol.png"
                    width: 64.0
                    height: 64.0
                }
            }
        }
    }
}
