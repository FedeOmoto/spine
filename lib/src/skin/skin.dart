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

/// Stores attachments by slot index and attachment name.
class Skin {
  static final SkinKey _lookup = new SkinKey();

  final String name;
  final Map<SkinKey, Attachment> attachments = new Map<SkinKey, Attachment>();

  Skin(this.name) {
    if (name == null) throw new ArgumentError('name cannot be null.');
  }

  void addAttachment(int slotIndex, String name, Attachment attachment) {
    if (attachment == null) throw new ArgumentError('attachment cannot be null.'
        );
    if (slotIndex < 0) throw new ArgumentError('slotIndex must be >= 0.');

    var key = new SkinKey();
    key.set(slotIndex, name);
    attachments[key] = attachment;
  }

  Attachment getAttachment(int slotIndex, String name) {
    if (slotIndex < 0) throw new ArgumentError('slotIndex must be >= 0.');

    _lookup.set(slotIndex, name);

    return attachments[_lookup];
  }

  void findNamesForSlot(int slotIndex, List<String> names) {
    if (names == null) throw new ArgumentError('names cannot be null.');
    if (slotIndex < 0) throw new ArgumentError('slotIndex must be >= 0.');

    attachments.forEach((key, value) {
      if (key.slotIndex == slotIndex) names.add(key.name);
    });
  }

  void findAttachmentsForSlot(int slotIndex, List<Attachment> attachments) {
    if (attachments == null) throw new ArgumentError(
        'attachments cannot be null.');
    if (slotIndex < 0) throw new ArgumentError('slotIndex must be >= 0.');

    this.attachments.forEach((key, value) {
      if (key.slotIndex == slotIndex) attachments.add(value);
    });
  }

  void clear() => attachments.clear();

  @override
  String toString() => name;

  /**
   * Attach each attachment in this skin if the corresponding attachment in the
   * old skin is currently attached.
   */
  void attachAll(Skeleton skeleton, Skin oldSkin) {
    oldSkin.attachments.forEach((key, value) {
      int slotIndex = key.slotIndex;
      var slot = skeleton.slots[slotIndex];

      if (slot.attachment == value) {
        var attachment = getAttachment(slotIndex, key.name);
        if (attachment != null) slot.attachment = attachment;
      }
    });
  }
}
