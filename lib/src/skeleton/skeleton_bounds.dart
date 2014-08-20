// Spine Runtimes Software License
// Version 2.2
//
// Copyright (c) 2013, Esoteric Software
// All rights reserved.
//
// You are granted a perpetual, non-exclusive, non-sublicensable and
// non-transferable license to use, install, execute and perform the Spine
// Runtimes Software (the "Software") and derivative works solely for personal or
// internal use. Without the written permission of Esoteric Software (typically
// granted by licensing Spine), you may not (a) modify, translate, adapt or
// otherwise create derivative works, improvements of the Software or develop
// new applications using the Software or (b) remove, delete, alter or obscure
// any trademarks or any copyright, trademark, patent or other intellectual
// property or proprietary rights notices on or in the Software, including any
// copy thereof. Redistributions in binary or source form must include this
// license and terms.
//
// THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

part of spine;

// TODO: document.
class SkeletonBounds {
  double _minX, _minY, _maxX, _maxY;
  List<BoundingBoxAttachment> _boundingBoxes = new List<BoundingBoxAttachment>(
      );
  List<List<double>> _polygons = new List<List<double>>();
  PolygonPool _polygonPool = new PolygonPool();

  void update(Skeleton skeleton, bool updateAabb) {
    var slots = skeleton.slots;
    double x = skeleton.position.x,
        y = skeleton.position.y;

    _boundingBoxes.clear();
    _polygonPool.freeAll(_polygons);
    _polygons.clear();

    slots.forEach((slot) {
      var attachment = slot.attachment;

      if (attachment is BoundingBoxAttachment) {
        var boundingBox = attachment as BoundingBoxAttachment;

        _boundingBoxes.add(boundingBox);
        var polygon = _polygonPool.obtain();
        _polygons.add(polygon);
        polygon.length = boundingBox.vertices.length;

        boundingBox.computeWorldVertices(x, y, slot.bone, polygon);
      }
    });

    if (updateAabb) _aabbCompute();
  }

  void _aabbCompute() {
    double minX = 0x7FFFFFFF.toDouble(),
        minY = 0x7FFFFFFF.toDouble(),
        maxX = -0x80000000.toDouble(),
        maxY = -0x80000000.toDouble();

    _polygons.forEach((polygon) {
      for (int i = 0,
          n = polygon.length; i < n; i += 2) {
        double x = polygon[i];
        double y = polygon[i + 1];
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    });

    _minX = minX;
    _minY = minY;
    _maxX = maxX;
    _maxY = maxY;
  }

  /// Returns true if the axis aligned bounding box contains the point.
  bool aabbContainsPoint(double x, double y) {
    return x >= _minX && x <= _maxX && y >= _minY && y <= _maxY;
  }

  /// Returns true if the axis aligned bounding box intersects the line segment.
  bool aabbIntersectsSegment(double x1, double y1, double x2, double y2) {
    if ((x1 <= _minX && x2 <= _minX) || (y1 <= _minY && y2 <= _minY) || (x1 >=
        _maxX && x2 >= _maxX) || (y1 >= _maxY && y2 >= _maxY)) {
      return false;
    }

    double m = (y2 - y1) / (x2 - x1);
    double y = m * (_minX - x1) + y1;

    if (y > _minY && y < _maxY) return true;
    y = m * (_maxX - x1) + y1;
    if (y > _minY && y < _maxY) return true;
    double x = (_minY - y1) / m + x1;
    if (x > _minX && x < _maxX) return true;
    x = (_maxY - y1) / m + x1;
    if (x > _minX && x < _maxX) return true;

    return false;
  }

  /**
   * Returns true if the axis aligned bounding box intersects the axis aligned
   * bounding box of the specified bounds.
   */
  bool aabbIntersectsSkeleton(SkeletonBounds bounds) {
    return _minX < bounds._maxX && _maxX > bounds._minX && _minY < bounds._maxY
        && _maxY > bounds._minY;
  }

  /**
   * Returns the first bounding box attachment that contains the point, or null.
   * When doing many checks, it is usually more efficient to only call this
   * method if [aabbContainsPoint] returns true.
   */
  BoundingBoxAttachment containsPoint(double x, double y) {
    for (int i = 0,
        n = _polygons.length; i < n; i++) {
      if (polygonContainsPoint(_polygons[i], x, y)) return _boundingBoxes[i];
    }

    return null;
  }

  /// Returns true if the polygon contains the point.
  bool polygonContainsPoint(List<double> polygon, double x, double y) {
    int nn = polygon.length;
    int prevIndex = nn - 2;
    bool inside = false;

    for (int ii = 0; ii < nn; ii += 2) {
      double vertexY = polygon[ii + 1];
      double prevY = polygon[prevIndex + 1];

      if ((vertexY < y && prevY >= y) || (prevY < y && vertexY >= y)) {
        double vertexX = polygon[ii];

        if (vertexX + (y - vertexY) / (prevY - vertexY) * (polygon[prevIndex] -
            vertexX) < x) {
          inside = !inside;
        }
      }

      prevIndex = ii;
    }

    return inside;
  }

  /**
   * Returns the first bounding box attachment that contains the line segment,
   * or null. When doing many checks, it is usually more efficient to only call
   * this method if [aabbIntersectsSegment] returns true. */
  BoundingBoxAttachment intersectsSegment(double x1, double y1, double
      x2, double y2) {
    for (int i = 0,
        n = _polygons.length; i < n; i++) {
      if (polygonIntersectsSegment(_polygons[i], x1, y1, x2, y2)) {
        return _boundingBoxes[i];
      }
    }

    return null;
  }

  /// Returns true if the polygon contains the line segment.
  bool polygonIntersectsSegment(List<double> polygon, double x1, double
      y1, double x2, double y2) {
    int nn = polygon.length;

    double width12 = x1 - x2,
        height12 = y1 - y2;
    double det1 = x1 * y2 - y1 * x2;
    double x3 = polygon[nn - 2],
        y3 = polygon[nn - 1];

    for (int ii = 0; ii < nn; ii += 2) {
      double x4 = polygon[ii],
          y4 = polygon[ii + 1];
      double det2 = x3 * y4 - y3 * x4;
      double width34 = x3 - x4,
          height34 = y3 - y4;
      double det3 = width12 * height34 - height12 * width34;
      double x = (det1 * width34 - width12 * det2) / det3;

      if (((x >= x3 && x <= x4) || (x >= x4 && x <= x3)) && ((x >= x1 && x <=
          x2) || (x >= x2 && x <= x1))) {
        double y = (det1 * height34 - height12 * det2) / det3;
        if (((y >= y3 && y <= y4) || (y >= y4 && y <= y3)) && ((y >= y1 && y <=
            y2) || (y >= y2 && y <= y1))) {
          return true;
        }
      }

      x3 = x4;
      y3 = y4;
    }

    return false;
  }

  double get minX => _minX;

  double get minY => _minY;

  double get maxX => _maxX;

  double get maxY => _maxY;

  double get width => _maxX - _minX;

  double get height => _maxY - _minY;

  List<BoundingBoxAttachment> get boundingBoxes => _boundingBoxes;

  List<List<double>> get polygons => _polygons;

  /// Returns the polygon for the specified bounding box, or null.
  List<double> getPolygon(BoundingBoxAttachment boundingBox) {
    int index = _boundingBoxes.indexOf(boundingBox);
    return index == -1 ? null : _polygons[index];
  }
}
