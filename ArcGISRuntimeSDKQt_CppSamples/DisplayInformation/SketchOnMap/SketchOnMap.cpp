// [WriteFile Name=SketchOnMap, Category=DisplayInformation]
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

#ifdef PCH_BUILD
#include "pch.hpp"
#endif // PCH_BUILD

#include "SketchOnMap.h"

#include "Map.h"
#include "MapQuickView.h"

#include "PolygonBuilder.h"
#include "SimpleFillSymbol.h"
#include "SimpleMarkerSymbol.h"
#include "SketchEditor.h"

using namespace Esri::ArcGISRuntime;

SketchOnMap::SketchOnMap(QObject* parent /* = nullptr */):
  QObject(parent),
  m_map(new Map(BasemapStyle::ArcGISImagery, this))
{
  // Create a GraphicsOverlay to save the sketches to
  m_sketchOverlay = new GraphicsOverlay(this);
  createSymbols();
}

SketchOnMap::~SketchOnMap() = default;

void SketchOnMap::init()
{
  // Register the map view for QML
  qmlRegisterType<MapQuickView>("Esri.Samples", 1, 0, "MapView");
  qmlRegisterType<SketchOnMap>("Esri.Samples", 1, 0, "SketchOnMapSample");
}

MapQuickView* SketchOnMap::mapView() const
{
  return m_mapView;
}

// Set the view (created in QML)
void SketchOnMap::setMapView(MapQuickView* mapView)
{
  if (!mapView || mapView == m_mapView)
    return;

  m_mapView = mapView;
  m_mapView->setMap(m_map);
  m_mapView->setViewpointCenter(Point(-15.5314, 64.3286, SpatialReference::wgs84()), 100'000);

  m_mapView->graphicsOverlays()->append(m_sketchOverlay);

  m_sketchEditor = new SketchEditor(this);
  m_mapView->setSketchEditor(m_sketchEditor);

  emit mapViewChanged();
}

void SketchOnMap::setSketchCreationMode(SampleSketchMode sketchCreationMode)
{
  switch(sketchCreationMode)
  {
    case SampleSketchMode::PointSketchMode:
      m_sketchEditor->start(SketchCreationMode::Point);
      break;

    case SampleSketchMode::MultipointSketchMode:
      m_sketchEditor->start(SketchCreationMode::Multipoint);
      break;

    case SampleSketchMode::PolylineSketchMode:
      m_sketchEditor->start(SketchCreationMode::Polyline);
      break;

    case SampleSketchMode::PolygonSketchMode:
      m_sketchEditor->start(SketchCreationMode::Polygon);
      break;

    default:
      break;
  }
  sketchEditorStartedChanged();
}

void SketchOnMap::stopSketching(bool saveGeometry)
{
  if (!m_sketchEditor->isStarted() || !saveGeometry)
  {
    m_sketchEditor->stop();
    sketchEditorStartedChanged();
    return;
  }

  if (!m_sketchEditor->isSketchValid())
  {
    qWarning() << "Unable to save sketch. Sketch is not valid.";
    return;
  }

  // To save the sketch, create a graphic with the sketch's geometry before stopping the sketchEditor
  Geometry sketchGeometry = m_sketchEditor->geometry();
  Symbol* geometrySymbol = nullptr;

  switch (m_sketchEditor->creationMode())
  {
    case SketchCreationMode::Point:
      geometrySymbol = m_pointSymbol;
      break;

    case SketchCreationMode::Multipoint:
      geometrySymbol = m_multiPointSymbol;
      break;

    case SketchCreationMode::Polyline:
      geometrySymbol = m_lineSymbol;
      break;

    case SketchCreationMode::Polygon:
      geometrySymbol = m_polygonSymbol;
      break;

    default:
      return;
  }

  Graphic* sketchGraphic = new Graphic(sketchGeometry, geometrySymbol, this);
  m_sketchOverlay->graphics()->append(sketchGraphic);

  m_sketchEditor->stop();
  sketchEditorStartedChanged();
}

bool SketchOnMap::sketchEditorStarted() const
{
  if (m_sketchEditor)
    return m_sketchEditor->isStarted();

  return false;
}

void SketchOnMap::createSymbols()
{
  m_pointSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Square, QColor(255, 0, 0), 10, this);
  m_multiPointSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Square, QColor(0, 0, 255), 10, this);
  m_lineSymbol = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor(144, 238, 144), 3, this);
  m_polygonSymbol = new SimpleFillSymbol(SimpleFillSymbolStyle::Solid, QColor(67, 166, 198, 119),
                                         new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor(67, 166, 198), 2.0, this), this);
}

void SketchOnMap::deleteVertex()
{
  if (m_sketchEditor->geometry().extent().isValid())
    m_sketchEditor->removeSelectedVertex();
}

void SketchOnMap::clearGraphics()
{
  m_sketchOverlay->graphics()->clear();
}

void SketchOnMap::undo()
{
  m_sketchEditor->undo();
}

void SketchOnMap::redo()
{
  m_sketchEditor->redo();
}
