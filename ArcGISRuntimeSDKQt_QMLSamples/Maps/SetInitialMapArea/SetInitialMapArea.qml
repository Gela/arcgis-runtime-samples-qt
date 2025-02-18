// [WriteFile Name=SetInitialMapArea, Category=Maps]
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
import Esri.ArcGISRuntime 100.12

Rectangle {
    width: 800
    height: 600

    // Create MapView that contains a Map with the Imagery Basemap
    MapView {
        id: mapView
        anchors.fill: parent
        Map {
            Basemap {
                initStyle: Enums.BasemapStyleArcGISImageryStandard
            }
            initialViewpoint: viewpoint
        }
    }

    // Create the intial Viewpoint
    ViewpointExtent {
        id: viewpoint
        extent: Envelope {
            xMin: -12211308.778729
            yMin: 4645116.003309
            xMax: -12208257.879667
            yMax: 4650542.535773
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }
}
