//
// Created by Matt Blair on 10/6/18.
//

#include "sphericalMercator.h"

namespace Tangram {

ProjectedMeters SphericalMercator::lngLatToProjectedMeters(LngLat coordinates) {
    ProjectedMeters meters;
    meters.x = coordinates.longitude * MapProjection::EARTH_HALF_CIRCUMFERENCE_METERS / 180.0;
    meters.y = log(tan(PI * 0.25 + coordinates.latitude * PI / 360.0)) * MapProjection::EARTH_RADIUS_METERS;
    return meters;
}

LngLat SphericalMercator::projectedMetersToLngLat(ProjectedMeters meters) {
    LngLat coordinates;
    coordinates.longitude = meters.x * 180.0 / MapProjection::EARTH_HALF_CIRCUMFERENCE_METERS;
    coordinates.latitude = (2.0 * atan(exp(meters.y / MapProjection::EARTH_RADIUS_METERS)) - PI * 0.5) * 180 / PI;
    return coordinates;
}

ProjectedMeters SphericalMercator::tileCoordinatesToProjectedMeters(TileCoordinates tileCoordinates) {
    double metersPerTile = MapProjection::EARTH_CIRCUMFERENCE_METERS / (1 << tileCoordinates.z);
    ProjectedMeters projectedMeters;
    projectedMeters.x = tileCoordinates.x * metersPerTile - MapProjection::EARTH_HALF_CIRCUMFERENCE_METERS;
    projectedMeters.y = MapProjection::EARTH_HALF_CIRCUMFERENCE_METERS - tileCoordinates.y * metersPerTile;
    return projectedMeters;
}

ProjectedMeters SphericalMercator::tileOrigin(TileID tile) {

}

ProjectedMeters SphericalMercator::tileCenter(TileID tile) {

}

BoundingBox SphericalMercator::tileBounds(TileID tile) {
    double tileSizeMeters = MapProjection::EARTH_CIRCUMFERENCE_METERS / (1 << tile.z);
    ProjectedMeters min(tile.x * tileSizeMeters, tile.y * tileSizeMeters);
    ProjectedMeters max(min.x + tileSizeMeters, min.y + tileSizeMeters);
    return BoundingBox {min, max};
}

ProjectedMeters SphericalMercator::tileSpan(Tangram::TileID tile) {
    double tileSizeMeters = MapProjection::EARTH_CIRCUMFERENCE_METERS / (1 << tile.z);
    return ProjectedMeters(tileSizeMeters, tileSizeMeters);
}



}