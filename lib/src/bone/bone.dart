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
class Bone {
  static bool yDown = true;

  final BoneData data;
  final Bone parent;
  double x, y;
  double rotation, rotationIK;
  double scaleX, scaleY;
  bool flipX = false,
      flipY = false;

  // a b x
  double m00, m01, worldX;

  // c d y
  double m10, m11, worldY;

  double worldRotation;
  double worldScaleX, worldScaleY;

  Bone(this.data, [this.parent]) {
    if (data == null) throw new ArgumentError('data cannot be null.');
    setToSetupPose();
  }

  /// Copy constructor.
  Bone.copy(Bone bone, [this.parent]) : data = bone.data {
    if (bone == null) throw new ArgumentError('bone cannot be null.');
    x = bone.x;
    y = bone.y;
    rotation = bone.rotation;
    rotationIK = bone.rotationIK;
    scaleX = bone.scaleX;
    scaleY = bone.scaleY;
    flipX = bone.flipX;
    flipY = bone.flipY;
  }

  /// Computes the world SRT using the parent bone and the local SRT.
  void updateWorldTransform() {
    if (parent != null) {
      worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
      worldY = x * parent.m10 + y * parent.m11 + parent.worldY;

      if (data.inheritScale) {
        worldScaleX = parent.worldScaleX * scaleX;
        worldScaleY = parent.worldScaleY * scaleY;
      } else {
        worldScaleX = scaleX;
        worldScaleY = scaleY;
      }

      worldRotation = data.inheritRotation ? parent.worldRotation + rotationIK :
          rotationIK;
    } else {
      worldX = flipX ? -x : x;
      worldY = flipY != yDown ? -y : y;
      worldScaleX = scaleX;
      worldScaleY = scaleY;
      worldRotation = rotationIK;
    }

    double radians = worldRotation * math.PI / 180;
    double cos = math.cos(radians);
    double sin = math.sin(radians);

    if (flipX) {
      m00 = -cos * worldScaleX;
      m01 = sin * worldScaleY;
    } else {
      m00 = cos * worldScaleX;
      m01 = -sin * worldScaleY;
    }

    if (flipY != yDown) {
      m10 = -sin * worldScaleX;
      m11 = -cos * worldScaleY;
    } else {
      m10 = sin * worldScaleX;
      m11 = cos * worldScaleY;
    }
  }

  void setToSetupPose() {
    x = data.x;
    y = data.y;
    rotation = data.rotation;
    rotationIK = rotation;
    scaleX = data.scaleX;
    scaleY = data.scaleY;
  }

  void set position(Point<double> value) {
    x = value.x;
    y = value.y;
  }

  void set scale(Point<double> value) {
    scaleX = value.x;
    scaleY = value.y;
  }

  Vector2 worldToLocal(Vector2 world) {
    double x = world.x - worldX,
        y = world.y - worldY;
    double m00 = this.m00,
        m10 = this.m10,
        m01 = this.m01,
        m11 = this.m11;

    if (flipX != flipY) {
      m00 *= -1;
      m11 *= -1;
    }

    double invDet = 1 / (m00 * m11 - m01 * m10);
    world.x = (x * m00 * invDet - y * m01 * invDet);
    world.y = (y * m11 * invDet - x * m10 * invDet);

    return world;
  }

  Vector2 localToWorld(Vector2 local) {
    double x = local.x,
        y = local.y;
    local.x = x * m00 + y * m01 + worldX;
    local.y = x * m10 + y * m11 + worldY;

    return local;
  }

  @override
  String toString() => data.name;
}
