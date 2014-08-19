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
class ColorTimeline extends CurveTimeline {
  static const int _PREV_FRAME_TIME = -5;
  static const int _FRAME_R = 1;
  static const int _FRAME_G = 2;
  static const int _FRAME_B = 3;
  static const int _FRAME_A = 4;

  int slotIndex;

  // time, r, g, b, a, ...
  final List<double> _frames;

  ColorTimeline(int frameCount)
      : _frames = new List<double>(frameCount * 5),
        super(frameCount);

  List<double> get getFrames => _frames;

  /// Sets the time and value of the specified keyframe.
  void setFrame(int frameIndex, double time, double r, double g, double
      b, double a) {
    frameIndex *= 5;
    _frames[frameIndex] = time;
    _frames[frameIndex + 1] = r;
    _frames[frameIndex + 2] = g;
    _frames[frameIndex + 3] = b;
    _frames[frameIndex + 4] = a;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      events, double alpha) {
    // Time is before first frame.
    if (time < _frames[0]) return;

    double r, g, b, a;

    if (time >= _frames[_frames.length - 5]) {
      // Time is after last frame.
      int i = _frames.length - 1;
      r = _frames[i - 3];
      g = _frames[i - 2];
      b = _frames[i - 1];
      a = _frames[i];
    } else {
      // Interpolate between the previous frame and the current frame.
      int frameIndex = Animation.binarySearch(_frames, time, 5);
      double prevFrameR = _frames[frameIndex - 4];
      double prevFrameG = _frames[frameIndex - 3];
      double prevFrameB = _frames[frameIndex - 2];
      double prevFrameA = _frames[frameIndex - 1];
      double frameTime = _frames[frameIndex];
      double percent = (1 - (time - frameTime) / (_frames[frameIndex +
          _PREV_FRAME_TIME] - frameTime)).clamp(0.0, 1.0);
      percent = getCurvePercent((frameIndex / 5 - 1).toInt(), percent);

      r = prevFrameR + (_frames[frameIndex + _FRAME_R] - prevFrameR) * percent;
      g = prevFrameG + (_frames[frameIndex + _FRAME_G] - prevFrameG) * percent;
      b = prevFrameB + (_frames[frameIndex + _FRAME_B] - prevFrameB) * percent;
      a = prevFrameA + (_frames[frameIndex + _FRAME_A] - prevFrameA) * percent;
    }

    var color = skeleton.slots[slotIndex].color;

    if (alpha < 1) {
      color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) *
          alpha, (a - color.a) * alpha);
    } else {
      color.setValues(r, g, b, a);
    }
  }
}
