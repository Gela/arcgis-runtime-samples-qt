// [WriteFile Name=RasterLayerService, Category=Layers]
// [Legal]
// Copyright 2017 Esri.

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
import QtQuick.Controls 2.2
import Esri.ArcGISRuntime 100.12

Rectangle {
    id: rootRectangle
    clip: true

    width: 800
    height: 600

    MapView {
        anchors.fill: parent
        id: mapView

        Map {
            // create a basemap from a tiled layer and add to the map
            Basemap {
                ArcGISTiledLayer {
                    url: "https://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
                }
            }

            // create and add a raster layer to the map
            RasterLayer {
                //! [ImageServiceRaster Create an image service raster]
                // create the raster layer from an image service raster
                ImageServiceRaster {
                    id: imageServiceRaster
                    url: "https://gis.ngdc.noaa.gov/arcgis/rest/services/bag_hillshades/ImageServer"

                    // zoom to the center of the raster once it's loaded
                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            const scale = 100000;
                            mapView.setViewpointCenterAndScale(ArcGISRuntimeEnvironment.createObject("Point", {x: -13643095.660131, y: 4550009.846004}), scale);
                        }
                    }
                }
                //! [ImageServiceRaster Create an image service raster]
            }
        }
    }
}
