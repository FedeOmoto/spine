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
class DrawOrderTimeline implements Timeline {
  final List<double> _frames; // time, ...
  final List<List<int>> _drawOrders;

  DrawOrderTimeline(int frameCount)
      : _frames = new List<double>(frameCount),
        _drawOrders = new List<List<int>>(frameCount);

  int get getFrameCount => _frames.length;

  List<double> get getFrames => _frames;

  List<List<int>> get getDrawOrders => _drawOrders;

  /// Sets the time of the specified keyframe.
  void setFrame(int frameIndex, double time, List<int> drawOrder) {
    _frames[frameIndex] = time;
    _drawOrders[frameIndex] = drawOrder;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      firedEvents, double alpha) {
    // Time is before first frame.
    if (time < _frames.first) return;

    int frameIndex;

    if (time >= _frames[_frames.length - 1]) {// Time is after last frame.
      frameIndex = _frames.length - 1;
    } else {
      frameIndex = Animation.binarySearch(_frames, time) - 1;
    }

    var drawOrder = skeleton.drawOrder;
    var slots = skeleton.slots;
    var drawOrderToSetupIndex = _drawOrders[frameIndex];

    if (drawOrderToSetupIndex == null) {
      drawOrder.clear();
      drawOrder.addAll(slots);
    } else {
      for (int i = 0,
          n = drawOrderToSetupIndex.length; i < n; i++) {
        drawOrder[i] = slots[drawOrderToSetupIndex[i]];
      }
    }
  }
}
