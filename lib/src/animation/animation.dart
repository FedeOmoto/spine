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
class Animation {
  final String name;
  final List<Timeline> timelines;

  /// The duration of the animation in seconds.
  double duration;

  Animation(this.name, this.timelines, this.duration) {
    if (name == null) throw new ArgumentError('name cannot be null.');
    if (timelines == null) throw new ArgumentError('timelines cannot be null.');
  }

  /// Poses the skeleton at the specified time for this animation.
  void apply(Skeleton skeleton, double lastTime, double time, bool
      loop, List<Event> events) {
    if (skeleton == null) throw new ArgumentError('skeleton cannot be null.');

    if (loop && duration != 0) {
      time %= duration;
      lastTime %= duration;
    }

    timelines.forEach((timeline) {
      timeline.apply(skeleton, lastTime, time, events, 1.0);
    });
  }

  /**
   * Poses the skeleton at the specified time for this animation mixed with the
   * current pose.
   */
  void mix(Skeleton skeleton, double lastTime, double time, bool
      loop, List<Event> events, double alpha) {
    if (skeleton == null) throw new ArgumentError('skeleton cannot be null.');

    if (loop && duration != 0) {
      lastTime %= duration;
      time %= duration;
    }

    timelines.forEach((timeline) {
      timeline.apply(skeleton, lastTime, time, events, alpha);
    });
  }

  @override
  String toString() => name;

  static int binarySearch(List<double> values, double target, [int step = 1]) {
    int low = 0;
    int high = (values.length / step - 2).toInt();

    if (high == 0) return step;

    int current = (high & 0xFFFFFFFF) >> 1;

    while (true) {
      if (values[(current + 1) * step] <= target) {
        low = current + 1;
      } else {
        high = current;
      }

      if (low == high) return (low + 1) * step;

      current = ((low + high) & 0xFFFFFFFF) >> 1;
    }
  }

  static int linearSearch(List<double> values, double target, int step) {
    for (int i = 0,
        last = values.length - step; i <= last; i += step) {
      if (values[i] > target) return i;
    }

    return -1;
  }
}
