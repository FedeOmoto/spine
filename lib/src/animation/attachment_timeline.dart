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
class AttachmentTimeline implements Timeline {
  int slotIndex;

  // time, ...
  final List<double> _frames;

  final List<String> _attachmentNames;

  AttachmentTimeline(int frameCount)
      : _frames = new List<double>(frameCount),
        _attachmentNames = new List<String>(frameCount);

  int get getFrameCount => _frames.length;

  List<double> get getFrames => _frames;

  List<String> get getAttachmentNames => _attachmentNames;

  /// Sets the time and value of the specified keyframe.
  void setFrame(int frameIndex, double time, String attachmentName) {
    _frames[frameIndex] = time;
    _attachmentNames[frameIndex] = attachmentName;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      events, double alpha) {
    if (time < _frames.first) {
      if (lastTime > time) {
        apply(skeleton, lastTime, 0x7FFFFFFF.toDouble(), null, 0.0);
      }

      return;
    } else if (lastTime > time) {
      lastTime = -1.0;
    }

    int frameIndex = time >= _frames.last ? _frames.length - 1 :
        Animation.binarySearch(_frames, time, 1) - 1;

    if (_frames[frameIndex] <= lastTime) return;

    var attachmentName = _attachmentNames[frameIndex];
    skeleton.slots[slotIndex].attachment = attachmentName == null ? null :
        skeleton.getAttachment(slotIndex, attachmentName);
  }
}
