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
class SkeletonData {
  String name;

  // Ordered parents first.
  final List<BoneData> bones = new List<BoneData>();

  // Setup pose draw order.
  final List<SlotData> slots = new List<SlotData>();

  final List<Skin> skins = new List<Skin>();
  Skin defaultSkin;
  final List<EventData> events = new List<EventData>();
  final List<Animation> animations = new List<Animation>();
  final List<IkConstraintData> ikConstraints = new List<IkConstraintData>();
  double width, height;
  String version, hash;

  BoneData findBone(String boneName) {
    if (boneName == null) throw new ArgumentError('boneName cannot be null.');

    for (var bone in bones) {
      if (bone.name == boneName) return bone;
    }

    return null;
  }

  int findBoneIndex(String boneName) {
    if (boneName == null) throw new ArgumentError('boneName cannot be null.');

    for (int i = 0,
        n = bones.length; i < n; i++) {
      if (bones[i].name == boneName) return i;
    }

    return -1;
  }

  SlotData findSlot(String slotName) {
    if (slotName == null) throw new ArgumentError('slotName cannot be null.');

    for (var slot in slots) {
      if (slot.name == slotName) return slot;
    }

    return null;
  }

  int findSlotIndex(String slotName) {
    if (slotName == null) throw new ArgumentError('slotName cannot be null.');

    for (int i = 0,
        n = slots.length; i < n; i++) {
      if (slots[i].name == slotName) return i;
    }

    return -1;
  }

  Skin findSkin(String skinName) {
    if (skinName == null) throw new ArgumentError('skinName cannot be null.');

    for (var skin in skins) {
      if (skin.name == skinName) return skin;
    }

    return null;
  }

  EventData findEvent(String eventDataName) {
    if (eventDataName == null) throw new ArgumentError(
        'eventDataName cannot be null.');

    for (EventData eventData in events) {
      if (eventData.name == eventDataName) return eventData;
    }

    return null;
  }

  Animation findAnimation(String animationName) {
    if (animationName == null) throw new ArgumentError(
        'animationName cannot be null.');

    for (var animation in animations) {
      if (animation.name == animationName) return animation;
    }

    return null;
  }

  IkConstraintData findIkConstraint(String ikConstraintName) {
    if (ikConstraintName == null) {
      throw new ArgumentError('ikConstraintName cannot be null.');
    }

    for (var ikConstraint in ikConstraints) {
      if (ikConstraint.name == ikConstraintName) return ikConstraint;
    }

    return null;
  }

  @override
  String toString() => name != null ? name : super.toString();
}
