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
class Slot {
  final SlotData data;
  final Bone bone;
  final Skeleton _skeleton;
  final Color color;
  Attachment _attachment;
  double _attachmentTime;
  List<double> attachmentVertices = new List<double>();

  Slot([SlotData data, this._skeleton, this.bone])
      : this.data = data,
        color = data == null ? new Color(0.0, 0.0, 0.0, 0.0) : new Color(1.0,
          1.0, 1.0, 1.0) {
    setToSetupPose(_skeleton.data.slots.indexOf(data));
  }

  /// Copy constructor.
  Slot.copy(Slot slot, this._skeleton, this.bone)
      : this.data = slot.data,
        color = new Color.from(slot.color) {
    if (slot == null) throw new ArgumentError('slot cannot be null.');
    if (_skeleton == null) throw new ArgumentError('skeleton cannot be null.');
    if (bone == null) throw new ArgumentError("bone cannot be null.");

    _attachment = slot._attachment;
    _attachmentTime = slot._attachmentTime;
  }

  Skeleton get getSkeleton => _skeleton;

  Attachment get attachment => _attachment;

  /**
   * Sets the attachment, resets [getAttachmentTime], and clears
   * [attachmentVertices].
   */
  void set attachment(Attachment attachment) {
    if (_attachment == attachment) return;
    _attachment = attachment;
    _attachmentTime = _skeleton.time;
    attachmentVertices.clear();
  }

  void set attachmentTime(double time) {
    _attachmentTime = _skeleton.time - time;
  }

  /// Returns the time since the attachment was set.
  double get attachmentTime => _skeleton.time - _attachmentTime;

  void setToSetupPose(int slotIndex) {
    color.set(data.color);
    attachment = data.attachmentName == null ? null : _skeleton.getAttachment(
        slotIndex, data.attachmentName);
    attachmentVertices.clear();
  }

  @override
  String toString() => data.name;
}
