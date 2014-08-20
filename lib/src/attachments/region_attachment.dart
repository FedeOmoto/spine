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

/// Attachment that displays a texture region.
class RegionAttachment extends Attachment {
  static const int X1 = 0;
  static const int Y1 = 1;
  static const int C1 = 2;
  static const int U1 = 3;
  static const int V1 = 4;
  static const int X2 = 5;
  static const int Y2 = 6;
  static const int C2 = 7;
  static const int U2 = 8;
  static const int V2 = 9;
  static const int X3 = 10;
  static const int Y3 = 11;
  static const int C3 = 12;
  static const int U3 = 13;
  static const int V3 = 14;
  static const int X4 = 15;
  static const int Y4 = 16;
  static const int C4 = 17;
  static const int U4 = 18;
  static const int V4 = 19;

  static const int BLX = 0;
  static const int BLY = 1;
  static const int ULX = 2;
  static const int ULY = 3;
  static const int URX = 4;
  static const int URY = 5;
  static const int BRX = 6;
  static const int BRY = 7;

  AtlasRegion _region;
  String path;
  double x,
      y,
      scaleX = 1.0,
      scaleY = 1.0,
      rotation,
      width,
      height;
  final List<double> _vertices = new List<double>(20);
  final List<double> _offset = new List<double>(8);
  final Color _color = new Color(1.0, 1.0, 1.0, 1.0);

  RegionAttachment(String name) : super(name);

  void updateOffset() {
    double localX2 = width / 2;
    double localY2 = height / 2;
    double localX = -localX2;
    double localY = -localY2;

    if (_region.rotate) {
      localX += _region.offsetX / _region.originalWidth * width;
      localY += _region.offsetY / _region.originalHeight * height;
      localX2 -= (_region.originalWidth - _region.offsetX -
          _region.packedHeight) / _region.originalWidth * width;
      localY2 -= (_region.originalHeight - _region.offsetY -
          _region.packedWidth) / _region.originalHeight * height;
    } else {
      localX += _region.offsetX / _region.originalWidth * width;
      localY += _region.offsetY / _region.originalHeight * height;
      localX2 -= (_region.originalWidth - _region.offsetX - _region.packedWidth)
          / _region.originalWidth * width;
      localY2 -= (_region.originalHeight - _region.offsetY -
          _region.packedHeight) / _region.originalHeight * height;
    }

    localX *= scaleX;
    localY *= scaleY;
    localX2 *= scaleX;
    localY2 *= scaleY;

    double radians = rotation * math.PI / 180;
    double cos = math.cos(radians);
    double sin = math.sin(radians);

    double localXCos = localX * cos + x;
    double localXSin = localX * sin;
    double localYCos = localY * cos + y;
    double localYSin = localY * sin;
    double localX2Cos = localX2 * cos + x;
    double localX2Sin = localX2 * sin;
    double localY2Cos = localY2 * cos + y;
    double localY2Sin = localY2 * sin;

    _offset[BLX] = localXCos - localYSin;
    _offset[BLY] = localYCos + localXSin;
    _offset[ULX] = localXCos - localY2Sin;
    _offset[ULY] = localY2Cos + localXSin;
    _offset[URX] = localX2Cos - localY2Sin;
    _offset[URY] = localY2Cos + localX2Sin;
    _offset[BRX] = localX2Cos - localYSin;
    _offset[BRY] = localYCos + localX2Sin;
  }

  void set region(AtlasRegion region) {
    if (region == null) throw new ArgumentError('region cannot be null.');

    _region = region;

    if (region.rotate) {
      _vertices[U3] = region.u;
      _vertices[V3] = region.v2;
      _vertices[U4] = region.u;
      _vertices[V4] = region.v;
      _vertices[U1] = region.u2;
      _vertices[V1] = region.v;
      _vertices[U2] = region.u2;
      _vertices[V2] = region.v2;
    } else {
      _vertices[U2] = region.u;
      _vertices[V2] = region.v2;
      _vertices[U3] = region.u;
      _vertices[V3] = region.v;
      _vertices[U4] = region.u2;
      _vertices[V4] = region.v;
      _vertices[U1] = region.u2;
      _vertices[V1] = region.v2;
    }
  }

  AtlasRegion get region {
    if (_region == null) throw new StateError('Region has not been set: $this');
    return _region;
  }

  void updateWorldVertices(Slot slot, bool premultipliedAlpha) {
    var skeleton = slot.getSkeleton;
    var skeletonColor = skeleton.color;
    var slotColor = slot.color;
    var regionColor = _color;
    double a = skeletonColor.a * slotColor.a * regionColor.a * 255;
    double multiplier = premultipliedAlpha ? a : 255.0;
    double color = Color.intToFloatColor((a.truncate() << 24) |
        ((skeletonColor.b * slotColor.b * regionColor.b * multiplier).truncate() << 16)
        | ((skeletonColor.g * slotColor.g * regionColor.g * multiplier).truncate() << 8)
        | (skeletonColor.r * slotColor.r * regionColor.r * multiplier).truncate());

    var bone = slot.bone;
    double x = skeleton.position.x + bone.worldX,
        y = skeleton.position.y + bone.worldY;
    double m00 = bone.m00,
        m01 = bone.m01,
        m10 = bone.m10,
        m11 = bone.m11;
    double offsetX, offsetY;

    offsetX = _offset[BRX];
    offsetY = _offset[BRY];
    _vertices[X1] = offsetX * m00 + offsetY * m01 + x; // br
    _vertices[Y1] = offsetX * m10 + offsetY * m11 + y;
    _vertices[C1] = color;

    offsetX = _offset[BLX];
    offsetY = _offset[BLY];
    _vertices[X2] = offsetX * m00 + offsetY * m01 + x; // bl
    _vertices[Y2] = offsetX * m10 + offsetY * m11 + y;
    _vertices[C2] = color;

    offsetX = _offset[ULX];
    offsetY = _offset[ULY];
    _vertices[X3] = offsetX * m00 + offsetY * m01 + x; // ul
    _vertices[Y3] = offsetX * m10 + offsetY * m11 + y;
    _vertices[C3] = color;

    offsetX = _offset[URX];
    offsetY = _offset[URY];
    _vertices[X4] = offsetX * m00 + offsetY * m01 + x; // ur
    _vertices[Y4] = offsetX * m10 + offsetY * m11 + y;
    _vertices[C4] = color;
  }

  List<double> get getWorldVertices => _vertices;

  List<double> get getOffset => _offset;

  Color get getColor => _color;
}
