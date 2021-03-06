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
class MeshAttachment extends Attachment {
  AtlasRegion _region;
  String path;
  List<double> vertices, regionUVs;
  List<int> triangles;
  List<double> _worldVertices;
  final Color _color = new Color(1.0, 1.0, 1.0, 1.0);
  int hullLength;

  // Nonessential.
  List<int> edges;
  double width, height;

  MeshAttachment(String name) : super(name);

  void set region(AtlasRegion region) {
    if (region == null) throw new ArgumentError('region cannot be null.');
    _region = region;
  }

  AtlasRegion get region {
    if (_region == null) throw new StateError('Region has not been set: $this');
    return _region;
  }

  void updateUVs() {
    int verticesLength = vertices.length;
    int worldVerticesLength = (verticesLength / 2 * 5).toInt();

    if (_worldVertices == null ||
        _worldVertices.length != worldVerticesLength) {
      _worldVertices = new List<double>(worldVerticesLength);
    }

    double u, v, width, height;

    if (_region == null) {
      u = v = 0.0;
      width = height = 1.0;
    } else {
      u = _region.u;
      v = _region.v;
      width = _region.u2 - u;
      height = _region.v2 - v;
    }

    if (_region != null && _region.rotate) {
      for (int i = 0,
          w = 3; i < verticesLength; i += 2, w += 5) {
        _worldVertices[w] = u + regionUVs[i + 1] * width;
        _worldVertices[w + 1] = v + height - regionUVs[i] * height;
      }
    } else {
      for (int i = 0,
          w = 3; i < verticesLength; i += 2, w += 5) {
        _worldVertices[w] = u + regionUVs[i] * width;
        _worldVertices[w + 1] = v + regionUVs[i + 1] * height;
      }
    }
  }

  void updateWorldVertices(Slot slot, bool premultipliedAlpha) {
    var skeleton = slot.getSkeleton;
    var skeletonColor = skeleton.color;
    var slotColor = slot.color;
    var meshColor = _color;
    double a = skeletonColor.a * slotColor.a * meshColor.a * 255;
    double multiplier = premultipliedAlpha ? a : 255.0;
    double color =
        Color.intToFloatColor(
            (a.truncate() << 24) |
                ((skeletonColor.b * slotColor.b * meshColor.b * multiplier).truncate() << 16) |
                ((skeletonColor.g * slotColor.g * meshColor.g * multiplier).truncate() << 8) |
                (skeletonColor.r * slotColor.r * meshColor.r * multiplier).truncate());

    var slotVertices = slot.attachmentVertices;

    if (slotVertices.length == vertices.length) vertices = slotVertices;

    var bone = slot.bone;
    double x = skeleton.position.x + bone.worldX,
        y = skeleton.position.y + bone.worldY;
    double m00 = bone.m00,
        m01 = bone.m01,
        m10 = bone.m10,
        m11 = bone.m11;

    for (int v = 0,
        w = 0,
        n = _worldVertices.length; w < n; v += 2, w += 5) {
      num vx = vertices[v];
      num vy = vertices[v + 1];
      _worldVertices[w] = vx * m00 + vy * m01 + x;
      _worldVertices[w + 1] = vx * m10 + vy * m11 + y;
      _worldVertices[w + 2] = color;
    }
  }

  List<double> get worldVertices => _worldVertices;

  Color get color => _color;
}
