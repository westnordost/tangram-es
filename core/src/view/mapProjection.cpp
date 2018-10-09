/*
 * Reference used for implementation: http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
 */

#include "view/mapProjection.h"
#include "view/sphericalMercator.h"

#include <cmath>

namespace Tangram {

MercatorProjection::MercatorProjection(int _tileSize) : m_tileSize(_tileSize) {
}

ProjectedMeters MercatorProjection::lngLatToProjectedMeters(LngLat coordinates) const {
    return SphericalMercator::lngLatToProjectedMeters(coordinates);
}

LngLat MercatorProjection::projectedMetersToLngLat(ProjectedMeters meters) const {
    return SphericalMercator::projectedMetersToLngLat(meters);
}

BoundingBox MercatorProjection::tileBoundsInProjectedMeters(TileID tile) const {
    return SphericalMercator::tileBounds(tile);
}

glm::dvec2 MercatorProjection::TileCenter(TileID tile) const {
    return SphericalMercator::tileCenter(tile);
}

// Reference: https://en.wikipedia.org/wiki/Mercator_projection#Truncation_and_aspect_ratio
BoundingBox MercatorProjection::CoordinateBounds() const {
    return { glm::dvec2(-180, -85.05113), glm::dvec2(180, 85.05113) } ;
}

BoundingBox MercatorProjection::ProjectedBounds() const {
    BoundingBox bound = CoordinateBounds();
    return {lngLatToProjectedMeters(bound.min), lngLatToProjectedMeters(bound.max) };
}

double MercatorProjection::TileSize() const { return m_tileSize; }

}
