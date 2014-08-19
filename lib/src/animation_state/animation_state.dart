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

/// Stores state for an animation and automatically mixes between animations.
class AnimationState {
  final AnimationStateData _data;
  List<TrackEntry> _tracks = new List<TrackEntry>();
  final List<Event> _events = new List<Event>();
  final List<AnimationStateListener> _listeners =
      new List<AnimationStateListener>();
  double timeScale = 1.0;

  TrackEntryPool _trackEntryPool = new TrackEntryPool();

  AnimationState(this._data) {
    if (_data == null) throw new ArgumentError('data cannot be null.');
  }

  void update(double delta) {
    delta *= timeScale;

    for (int i = 0; i < _tracks.length; i++) {
      var current = _tracks[i];

      if (current == null) continue;

      current.time += delta * current.timeScale;

      if (current.previous != null) {
        double previousDelta = delta * current.previous.timeScale;
        current.previous.time += previousDelta;
        current.mixTime += previousDelta;
      }

      var next = current.next;

      if (next != null) {
        next.time = current.lastTime - next.delay;
        if (next.time >= 0) _setCurrent(i, next);
      } else {
        // End non-looping animation when it reaches its end time and there is
        // no next entry.
        if (!current.loop && current.lastTime >= current.endTime) clearTrack(i);
      }
    }
  }

  void apply(Skeleton skeleton) {
    int listenerCount = _listeners.length;

    for (int i = 0; i < _tracks.length; i++) {
      var current = _tracks[i];

      if (current == null) continue;

      _events.length = 0;

      double time = current.time;
      double lastTime = current.lastTime;
      double endTime = current.endTime;
      bool loop = current.loop;

      if (!loop && time > endTime) time = endTime;

      var previous = current.previous;

      if (previous == null) {
        if (current.mix == 1) {
          current.animation.apply(skeleton, lastTime, time, loop, _events);
        } else {
          current.animation.mix(skeleton, lastTime, time, loop, _events,
              current.mix);
        }
      } else {
        double previousTime = previous.time;

        if (!previous.loop && previousTime > previous.endTime) previousTime =
            previous.endTime;
        previous.animation.apply(skeleton, previousTime, previousTime,
            previous.loop, null);

        double alpha = current.mixTime / current.mixDuration * current.mix;

        if (alpha >= 1) {
          alpha = 1.0;
          _trackEntryPool.free(previous);
          current.previous = null;
        }

        current.animation.mix(skeleton, lastTime, time, loop, _events, alpha);
      }

      for (int ii = 0,
          nn = _events.length; ii < nn; ii++) {
        var event = _events[ii];

        if (current.listener != null) current.listener.event(i, event);

        for (int iii = 0; iii < listenerCount; iii++) {
          _listeners[iii].event(i, event);
        }
      }

      // Check if completed the animation or a loop iteration.
      if (loop ? (lastTime % endTime > time % endTime) : (lastTime < endTime &&
          time >= endTime)) {
        int count = time ~/ endTime;

        if (current.listener != null) current.listener.complete(i, count);

        for (int ii = 0,
            nn = _listeners.length; ii < nn; ii++) {
          _listeners[ii].complete(i, count);
        }
      }

      current.lastTime = current.time;
    }
  }

  void clearTracks() {
    for (int i = 0,
        n = _tracks.length; i < n; i++) {
      clearTrack(i);
    }

    _tracks.clear();
  }

  void clearTrack(int trackIndex) {
    if (trackIndex >= _tracks.length) return;

    var current = _tracks[trackIndex];

    if (current == null) return;

    if (current.listener != null) current.listener.end(trackIndex);

    for (int i = 0,
        n = _listeners.length; i < n; i++) {
      _listeners[i].end(trackIndex);
    }

    _tracks[trackIndex] = null;

    _freeAll(current);

    if (current.previous != null) _trackEntryPool.free(current.previous);
  }

  void _freeAll(TrackEntry entry) {
    while (entry != null) {
      var next = entry.next;
      _trackEntryPool.free(entry);
      entry = next;
    }
  }

  TrackEntry _expandToIndex(int index) {
    if (index < _tracks.length) return _tracks[index];
    _tracks.length = index + 1;
    return null;
  }

  void _setCurrent(int index, TrackEntry entry) {
    var current = _expandToIndex(index);

    if (current != null) {
      var previous = current.previous;

      current.previous = null;

      if (current.listener != null) current.listener.end(index);

      for (int i = 0,
          n = _listeners.length; i < n; i++) {
        _listeners[i].end(index);
      }

      entry.mixDuration = _data.getMix(current.animation, entry.animation);

      if (entry.mixDuration > 0) {
        entry.mixTime = 0.0;

        // If a mix is in progress, mix from the closest animation.
        if (previous != null && current.mixTime / current.mixDuration < 0.5) {
          entry.previous = previous;
          previous = current;
        } else {
          entry.previous = current;
        }
      } else {
        _trackEntryPool.free(current);
      }

      if (previous != null) _trackEntryPool.free(previous);
    }

    _tracks[index] = entry;

    if (entry.listener != null) entry.listener.start(index);

    for (int i = 0,
        n = _listeners.length; i < n; i++) {
      _listeners[i].start(index);
    }
  }

  /// See [setAnimation].
  TrackEntry setAnimationByName(int trackIndex, String animationName, bool loop)
      {
    Animation animation = _data.getSkeletonData.findAnimation(animationName);
    if (animation == null) throw new ArgumentError(
        'Animation not found: $animationName');
    return setAnimation(trackIndex, animation, loop);
  }

  /// Set the current animation. Any queued animations are cleared.
  TrackEntry setAnimation(int trackIndex, Animation animation, bool loop) {
    var current = _expandToIndex(trackIndex);

    if (current != null) _freeAll(current.next);

    var entry = _trackEntryPool.obtain();

    entry.animation = animation;
    entry.loop = loop;
    entry.endTime = animation.duration;
    _setCurrent(trackIndex, entry);

    return entry;
  }

  TrackEntry addAnimationByName(int trackIndex, String animationName, bool
      loop, double delay) {
    Animation animation = _data.getSkeletonData.findAnimation(animationName);
    if (animation == null) throw new ArgumentError(
        'Animation not found: $animationName');
    return addAnimation(trackIndex, animation, loop, delay);
  }

  /**
   * Adds an animation to be played delay seconds after the current or last
   * queued animation.
   */
  TrackEntry addAnimation(int trackIndex, Animation animation, bool loop, double
      delay) {
    var entry = _trackEntryPool.obtain();
    entry.animation = animation;
    entry.loop = loop;
    entry.endTime = animation.duration;

    var last = _expandToIndex(trackIndex);

    if (last != null) {
      while (last.next != null) {
        last = last.next;
      }

      last.next = entry;
    } else {
      _tracks[trackIndex] = entry;
    }

    if (delay <= 0) {
      if (last != null) {
        delay += last.endTime - _data.getMix(last.animation, animation);
      } else {
        delay = 0.0;
      }
    }

    entry.delay = delay;

    return entry;
  }

  TrackEntry getCurrent(int trackIndex) {
    if (trackIndex >= _tracks.length) return null;
    return _tracks[trackIndex];
  }

  /// Adds a listener to receive events for all animations.
  void addListener(AnimationStateListener listener) {
    if (listener == null) throw new ArgumentError('listener cannot be null.');
    _listeners.add(listener);
  }

  /// Removes the listener added with [addListener]
  void removeListener(AnimationStateListener listener) {
    _listeners.remove(listener);
  }

  AnimationStateData get getData => _data;

  /// Returns the list of tracks that have animations, which may contain nulls.
  List<TrackEntry> get getTracks => _tracks;

  @override
  String toString() {
    String buffer = '';

    for (var entry in _tracks) {
      if (entry == null) continue;
      if (buffer.isNotEmpty) buffer += ', ';
      buffer += entry.toString();
    }

    if (buffer.isEmpty) return '<none>';

    return buffer;
  }
}
