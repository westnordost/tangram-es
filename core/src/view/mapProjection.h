#pragma once

#include "tile/tileID.h"
#include "util/geom.h"
#include "util/types.h"

namespace Tangram {

/*
Projected Meters
----------------
 Map projections define a 2D coordinate system whose origin is at longitude and
 latitude zero and whose minimum and maximum values are given by ProjectedBounds().

 +------------------+
 |        |         |
 |     +y ^         |
 |        |   +x    |     N
 |---<----+---->----|  W <|> E
 |        |(0,0)    |     S
 |        v         |
 |        |         |
 +------------------+
*/
using ProjectedMeters = glm::dvec2;

/*
Tile Coordinates
----------------
 Tiles are addressed within a 2D coordinate system at each zoom level whose
 origin is at the upper-left corner of the spherical mercator projection space.
 The space is divided into 2^z tiles at each zoom, so that the boundary of the
 coordinates in each dimension is 2^z.

 +------>-----------+
 |(0,0) +x|         | (2^z,0)
 |        |         |
 v +y     |         |     N
 |--------+---------|  W <|> E
 |        |         |     S
 |        |         |
 |        |         |
 +------------------+
  (0,2^z)             (2^z,2^z)
*/
struct TileCoordinates {
    double x;
    double y;
    int z;
};

class MapProjection {

public:

    constexpr static double EARTH_RADIUS_METERS = 6378137.0;
    constexpr static double EARTH_HALF_CIRCUMFERENCE_METERS = PI * EARTH_RADIUS_METERS;
    constexpr static double EARTH_CIRCUMFERENCE_METERS = 2 * PI * EARTH_RADIUS_METERS;

    virtual ~MapProjection() = default;

    virtual ProjectedMeters lngLatToProjectedMeters(LngLat coordinates) const = 0;

    virtual LngLat projectedMetersToLngLat(ProjectedMeters meters) const = 0;

    virtual BoundingBox tileBoundsInProjectedMeters(TileID tile) const = 0;

    virtual ProjectedMeters TileCenter(TileID tile) const = 0;

    /*
     * Returns the bounds (projection units) of the map per the map projection
     */
    virtual BoundingBox ProjectedBounds() const = 0;

    /*
     * Returns the bounds (lng, lat) of the map per the map projection
     */
    virtual BoundingBox CoordinateBounds() const = 0;

    virtual double TileSize() const = 0;

};

class MercatorProjection : public MapProjection {
    int m_tileSize;

public:

    explicit MercatorProjection(int  _tileSize=256);

    ~MercatorProjection() override = default;

    ProjectedMeters lngLatToProjectedMeters(LngLat coordinates) const override;
    LngLat projectedMetersToLngLat(ProjectedMeters meters) const override;
    BoundingBox tileBoundsInProjectedMeters(TileID tile) const override;
    ProjectedMeters TileCenter(TileID tile) const override;
    BoundingBox ProjectedBounds() const override;
    BoundingBox CoordinateBounds() const override;
    double TileSize() const override;
};

}
