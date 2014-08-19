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
class EventTimeline implements Timeline {
  // time, ...
  final List<double> _frames;

  final List<Event> _events;

  EventTimeline(int frameCount)
      : _frames = new List<double>(frameCount),
        _events = new List<Event>(frameCount);

  int get getFrameCount => _frames.length;

  List<double> get getFrames => _frames;

  List<Event> get getEvents => _events;

  /// Sets the time of the specified keyframe.
  void setFrame(int frameIndex, double time, Event event) {
    _frames[frameIndex] = time;
    _events[frameIndex] = event;
  }

  /// Fires events for frames > [lastTime] and <= [time].
  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      firedEvents, double alpha) {
    if (firedEvents == null) return;

    int frameCount = _frames.length;

    if (lastTime > time) { // Fire events after last time for looped animations.
      apply(skeleton, lastTime, 0x7FFFFFFF.toDouble(), firedEvents, alpha);
      lastTime = -1.0;
    } else if (lastTime >= _frames[frameCount - 1])
        {// Last time is after last frame.
      return;
    }

    // Time is before first frame.
    if (time < _frames[0]) return;

    int frameIndex;

    if (lastTime < _frames[0]) {
      frameIndex = 0;
    } else {
      frameIndex = Animation.binarySearch(_frames, lastTime);
      double frame = _frames[frameIndex];

      // Fire multiple events with the same frame.
      while (frameIndex > 0) {
        if (_frames[frameIndex - 1] != frame) break;
        frameIndex--;
      }
    }

    for ( ; frameIndex < frameCount && time >= _frames[frameIndex];
        frameIndex++) {
      firedEvents.add(_events[frameIndex]);
    }
  }
}
