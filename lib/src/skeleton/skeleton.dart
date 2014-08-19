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
class Skeleton {
  final SkeletonData data;
  final List<Bone> bones;
  final List<Slot> slots;
  final List<IkConstraint> ikConstraints;
  final List<List<Bone>> _updateBonesCache = new List<List<Bone>>();
  List<Slot> drawOrder;
  Skin skin;
  final Color color;
  double time;
  bool flipX, flipY;
  double x, y;

  Skeleton(SkeletonData data)
      : this.data = data,
        bones = new List<Bone>(data.bones.length),
        slots = new List<Slot>(data.slots.length),
        ikConstraints = new List<IkConstraint>(data.ikConstraints.length),
        color = new Color(1.0, 1.0, 1.0, 1.0) {
    if (data == null) throw new ArgumentError('data cannot be null.');

    for (int i = 0; i < data.bones.length; i++) {
      var boneData = data.bones[i];
      var parent = boneData.parent == null ? null : bones[data.bones.indexOf(
          boneData.parent)];

      bones[i] = new Bone(boneData, parent);
    }

    drawOrder = new List<Slot>(data.slots.length);

    for (int i = 0; i < data.slots.length; i++) {
      var slotData = data.slots[i];
      var bone = bones[data.bones.indexOf(slotData.boneData)];
      var slot = new Slot(slotData, this, bone);

      slots[i] = slot;
      drawOrder[i] = slot;
    }

    for (int i = 0; i < data.ikConstraints.length; i++) {
      var ikConstraintData = data.ikConstraints[i];
      ikConstraints[i] = new IkConstraint(ikConstraintData, this);
    }

    updateCache();
  }

  /// Copy constructor.
  Skeleton.copy(Skeleton skeleton)
      : data = skeleton.data,
        bones = new List<Bone>(skeleton.bones.length),
        slots = new List<Slot>(skeleton.slots.length),
        ikConstraints = new List<IkConstraint>(skeleton.ikConstraints.length),
        color = new Color.from(skeleton.color) {
    if (skeleton == null) throw new ArgumentError('skeleton cannot be null.');

    for (var bone in skeleton.bones) {
      var parent = bone.parent == null ? null : bones[skeleton.bones.indexOf(
          bone.parent)];

      bones.add(new Bone.copy(bone, parent));
    }

    for (var slot in skeleton.slots) {
      var bone = bones[skeleton.bones.indexOf(slot.bone)];
      slots.add(new Slot.copy(slot, this, bone));
    }

    drawOrder = new List<Slot>(slots.length);

    for (int i = 0; i < skeleton.drawOrder.length; i++) {
      var slot = skeleton.drawOrder[i];
      drawOrder[i] = slots[skeleton.slots.indexOf(slot)];
    }

    for (IkConstraint ikConstraint in skeleton.ikConstraints) {
      var target = bones[skeleton.bones.indexOf(ikConstraint.target)];
      List<Bone> ikBones = new List<Bone>(ikConstraint.bones.length);

      for (int i = 0; i < ikConstraint.bones.length; i++) {
        var bone = ikConstraint.bones[i];
        ikBones[i] = bones[skeleton.bones.indexOf(bone)];
      }

      ikConstraints.add(new IkConstraint.copy(ikConstraint, ikBones, target));
    }

    skin = skeleton.skin;
    time = skeleton.time;
    flipX = skeleton.flipX;
    flipY = skeleton.flipY;

    updateCache();
  }

  /**
   * Caches information about bones and IK constraints. Must be called if bones
   * or IK constraints are added or removed.
   */
  void updateCache() {
    int ikConstraintsCount = ikConstraints.length;
    int arrayCount = ikConstraintsCount + 1;

    if (_updateBonesCache.length > arrayCount) {
      _updateBonesCache.length = arrayCount;
    }

    _updateBonesCache.forEach((bones) => bones.clear());

    while (_updateBonesCache.length < arrayCount) {
      _updateBonesCache.add(new List<Bone>());
    }

    var nonIkBones = _updateBonesCache.first;

    outer: for (var bone in bones) {
      var current = bone;

      do {
        for (int i = 0; i < ikConstraintsCount; i++) {
          IkConstraint ikConstraint = ikConstraints[i];
          Bone parent = ikConstraint.bones.first;
          Bone child = ikConstraint.bones.last;

          while (true) {
            if (current == child) {
              _updateBonesCache[i].add(bone);
              _updateBonesCache[i + 1].add(bone);
              continue outer;
            }

            if (child == parent) break;
            child = child.parent;
          }
        }

        current = current.parent;
      } while (current != null);

      nonIkBones.add(bone);
    }
  }

  /// Updates the world transform for each bone and applies IK constraints.
  void updateWorldTransform() {
    bones.forEach((bone) => bone.rotationIK = bone.rotation);

    int i = 0,
        last = _updateBonesCache.length - 1;

    while (true) {
      var updateBones = _updateBonesCache[i];

      updateBones.forEach((bone) => bone.updateWorldTransform());

      if (i == last) break;
      ikConstraints[i].adjustRotation();
      i++;
    }
  }

  /// Sets the bones and slots to their setup pose values.
  void setToSetupPose() {
    setBonesToSetupPose();
    setSlotsToSetupPose();
  }

  void setBonesToSetupPose() {
    bones.forEach((bone) => bone.setToSetupPose());

    ikConstraints.forEach((ikConstraint) {
      ikConstraint.bendDirection = ikConstraint.data.bendDirection;
      ikConstraint.mix = ikConstraint.data.mix;
    });
  }

  void setSlotsToSetupPose() {
    drawOrder.setAll(0, slots);

    for (int i = 0,
        n = slots.length; i < n; i++) {
      slots[i].setToSetupPose(i);
    }
  }

  Bone getRootBone() {
    if (bones.isEmpty) return null;
    return bones.first;
  }

  Bone findBone(String boneName) {
    if (boneName == null) throw new ArgumentError('boneName cannot be null.');

    for (var bone in bones) {
      if (bone.data.name == boneName) return bone;
    }

    return null;
  }

  int findBoneIndex(String boneName) {
    if (boneName == null) throw new ArgumentError('boneName cannot be null.');

    for (int i = 0,
        n = bones.length; i < n; i++) {
      if (bones[i].data.name == boneName) return i;
    }

    return -1;
  }

  Slot findSlot(String slotName) {
    if (slotName == null) throw new ArgumentError('slotName cannot be null.');

    for (var slot in slots) {
      if (slot.data.name == slotName) return slot;
    }

    return null;
  }

  int findSlotIndex(String slotName) {
    if (slotName == null) throw new ArgumentError('slotName cannot be null.');

    for (int i = 0,
        n = slots.length; i < n; i++) {
      if (slots[i].data.name == slotName) return i;
    }

    return -1;
  }

  /// Sets a skin by name.
  void setSkinByName(String skinName) {
    var skin = data.findSkin(skinName);
    if (skin == null) throw new ArgumentError('Skin not found: $skinName');
    setSkin(skin);
  }

  /**
   * Sets the skin used to look up attachments not found in the
   * [SkeletonData.defaultSkin] default skin. Attachments from the new skin are
   * attached if the corresponding attachment from the old skin was attached. If
   * there was no old skin, each slot's setup mode attachment is attached from
   * the new skin.
   */
  void setSkin(Skin newSkin) {
    if (newSkin != null) {
      if (skin != null) {
        newSkin.attachAll(this, skin);
      } else {
        for (int i = 0,
            n = slots.length; i < n; i++) {
          var slot = slots[i];
          var name = slot.data.attachmentName;

          if (name != null) {
            var attachment = newSkin.getAttachment(i, name);
            if (attachment != null) slot.attachment = attachment;
          }
        }
      }
    }

    skin = newSkin;
  }

  Attachment getAttachmentByName(String slotName, String attachmentName) {
    return getAttachment(data.findSlotIndex(slotName), attachmentName);
  }

  Attachment getAttachment(int slotIndex, String attachmentName) {
    if (attachmentName == null) throw new ArgumentError(
        'attachmentName cannot be null.');

    if (skin != null) {
      Attachment attachment = skin.getAttachment(slotIndex, attachmentName);
      if (attachment != null) return attachment;
    }

    if (data.defaultSkin != null) {
      return data.defaultSkin.getAttachment(slotIndex, attachmentName);
    }

    return null;
  }

  void setAttachment(String slotName, String attachmentName) {
    if (slotName == null) throw new ArgumentError('slotName cannot be null.');

    for (int i = 0,
        n = slots.length; i < n; i++) {
      var slot = slots[i];

      if (slot.data.name == slotName) {
        var attachment;

        if (attachmentName != null) {
          attachment = getAttachment(i, attachmentName);

          if (attachment == null) {
            throw new ArgumentError(
                'Attachment not found: $attachmentName, for slot: $slotName');
          }
        }

        slot.attachment = attachment;

        return;
      }
    }

    throw new ArgumentError('Slot not found: $slotName');
  }

  IkConstraint findIkConstraint(String ikConstraintName) {
    if (ikConstraintName == null) throw new ArgumentError(
        'ikConstraintName cannot be null.');

    for (var ikConstraint in ikConstraints) {
      if (ikConstraint.data.name == ikConstraintName) return ikConstraint;
    }

    return null;
  }

  void setFlipX(bool flipX) {
    this.flipX = flipX;
    bones.forEach((bone) => bone.flipX = flipX);
  }

  void setFlipY(bool flipY) {
    if (this.flipY == flipY) return;
    this.flipY = flipY;
    bones.forEach((bone) => bone.flipY = flipY);
  }

  void setFlip(bool flipX, bool flipY) {
    bones.forEach((bone) {
      bone.flipX = flipX;
      bone.flipY = flipY;
    });
  }

  void setPosition(Point<double> value) {
    x = value.x;
    y = value.y;
  }

  void update(double delta) {
    time += delta;
  }

  @override
  String toString() => data.name != null ? data.name : super.toString();
}
