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
class IkConstraint {
  static final Vector2 _temp = new Vector2.zero();

  final IkConstraintData data;
  final List<Bone> bones;
  Bone target;
  double mix = 1.0;
  int bendDirection;

  IkConstraint(IkConstraintData ikData, Skeleton skeleton)
      : data = ikData,
        bones = new List<Bone>(ikData.bones.length) {
    mix = ikData.mix;
    bendDirection = ikData.bendDirection;

    if (skeleton != null) {
      ikData.bones.forEach((boneData) {
        bones.add(skeleton.findBone(boneData.name));
      });

      target = skeleton.findBone(ikData.target.name);
    }
  }

  /// Copy constructor.
  IkConstraint.copy(IkConstraint ikConstraint, this.bones, this.target) : data =
      ikConstraint.data {
    mix = ikConstraint.mix;
    bendDirection = ikConstraint.bendDirection;
  }

  void adjustRotation() {
    switch (bones.length) {
      case 1:
        apply(bones.first, target.worldX, target.worldY, mix);
        break;
      case 2:
        applyOnParentAndChild(bones.first, bones[1], target.worldX,
            target.worldY, bendDirection, mix);
        break;
    }
  }

  @override
  String toString() => data.name;

  /**
   * Adjusts the bone rotation so the tip is as close to the target position as
   * possible. The target is specified in the world coordinate system.
   */
  static void apply(Bone bone, double targetX, double targetY, double alpha) {
    double parentRotation = (!bone.data.inheritRotation || bone.parent == null)
        ? 0.0 : bone.parent.worldRotation;
    double rotation = bone.rotation;
    double rotationIK = math.atan2(targetY - bone.worldY, targetX - bone.worldX)
        * (180 / math.PI) - parentRotation;
    bone.rotationIK = rotation + (rotationIK - rotation) * alpha;
  }

  /**
   * Adjusts the parent and child bone rotations so the tip of the child is as
   * close to the target position as possible. The target is specified in the
   * world coordinate system.
   */
  static void applyOnParentAndChild(Bone parent, Bone child, double
      targetX, double targetY, int bendDirection, double alpha) {
    double childRotation = child.rotation,
        parentRotation = parent.rotation;

    if (alpha == 0) {
      child.rotationIK = childRotation;
      parent.rotationIK = parentRotation;
      return;
    }

    var position = _temp;
    var parentParent = parent.parent;

    if (parentParent != null) {
      parentParent.worldToLocal(position.setValues(targetX, targetY));
      targetX = (position.x - parent.x) * parentParent.worldScaleX;
      targetY = (position.y - parent.y) * parentParent.worldScaleY;
    } else {
      targetX -= parent.x;
      targetY -= parent.y;
    }

    if (child.parent == parent) {
      position.setValues(child.x, child.y);
    } else {
      parent.worldToLocal(child.parent.localToWorld(position.setValues(child.x,
          child.y)));
    }

    double childX = position.x * parent.worldScaleX,
        childY = position.y * parent.worldScaleY;
    double offset = math.atan2(childY, childX);
    double len1 = math.sqrt(childX * childX + childY * childY),
        len2 = child.data.length * child.worldScaleX;
    double cosDenom = 2 * len1 * len2;

    if (cosDenom < 0.0001) {
      child.rotationIK = childRotation + (math.atan2(targetY, targetX) * (180 /
          math.PI) - parentRotation - childRotation) * alpha;
      return;
    }

    double cos = ((targetX * targetX + targetY * targetY - len1 * len1 - len2 *
        len2) / cosDenom).clamp(-1.0, 1.0);
    double childAngle = math.acos(cos) * bendDirection;
    double adjacent = len1 + len2 * cos,
        opposite = len2 * math.sin(childAngle);
    double parentAngle = math.atan2(targetY * adjacent - targetX * opposite,
        targetX * adjacent + targetY * opposite);
    double rotation = (parentAngle - offset) * (180 / math.PI) - parentRotation;

    if (rotation > 180) {
      rotation -= 360;
    } else if (rotation < -180) {
      rotation += 360;
    }

    parent.rotationIK = parentRotation + rotation * alpha;
    rotation = (childAngle + offset) * (180 / math.PI) - childRotation;

    if (rotation > 180) {
      rotation -= 360;
    } else if (rotation < -180) {
      rotation += 360;
    }

    child.rotationIK = childRotation + (rotation + parent.worldRotation -
        child.parent.worldRotation) * alpha;
  }
}
