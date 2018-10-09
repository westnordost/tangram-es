//
// Created by Matt Blair on 10/6/18.
//

#pragma once

#include "util/geom.h"
#include "util/types.h"
#include "view/mapProjection.h"

namespace Tangram {

class SphericalMercator {

public:

    static ProjectedMeters lngLatToProjectedMeters(LngLat coordinates);

    static LngLat projectedMetersToLngLat(ProjectedMeters meters);

    static ProjectedMeters tileCoordinatesToProjectedMeters(TileCoordinates tileCoordinates);

    static ProjectedMeters tileOrigin(TileID tile);

    static ProjectedMeters tileCenter(TileID tile);

    static BoundingBox tileBounds(TileID tile);

    static ProjectedMeters tileSpan(TileID tile);

    /// Bounds of the map projection in projected meters.
    static BoundingBox mapProjectedMetersBounds();

    /// Bounds of the map projection in longitude and latitude.
    static BoundingBox mapLngLatBounds();

};

} // namespace Tangram
