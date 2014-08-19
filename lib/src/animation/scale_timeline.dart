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
class ScaleTimeline extends TranslateTimeline {
  ScaleTimeline(int frameCount) : super(frameCount);

  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      events, double alpha) {
    // Time is before first frame.
    if (time < _frames.first) return;

    Bone bone = skeleton.bones[boneIndex];

    // Time is after last frame.
    if (time >= _frames[_frames.length - 3]) {
      bone.scaleX += (bone.data.scaleX - 1 + _frames[_frames.length - 2] -
          bone.scaleX) * alpha;
      bone.scaleY += (bone.data.scaleY - 1 + _frames[_frames.length - 1] -
          bone.scaleY) * alpha;
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = Animation.binarySearch(_frames, time, 3);
    double prevFrameX = _frames[frameIndex - 2];
    double prevFrameY = _frames[frameIndex - 1];
    double frameTime = _frames[frameIndex];
    double percent = (1 - (time - frameTime) / (_frames[frameIndex +
        TranslateTimeline.PREV_FRAME_TIME] - frameTime)).clamp(0.0, 1.0);
    percent = getCurvePercent((frameIndex / 3 - 1).toInt(), percent);

    bone.scaleX += (bone.data.scaleX - 1 + prevFrameX + (_frames[frameIndex +
        TranslateTimeline.FRAME_X] - prevFrameX) * percent - bone.scaleX) * alpha;
    bone.scaleY += (bone.data.scaleY - 1 + prevFrameY + (_frames[frameIndex +
        TranslateTimeline.FRAME_Y] - prevFrameY) * percent - bone.scaleY) * alpha;
  }
}
