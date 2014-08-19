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

/// A pool of objects that can be reused to avoid allocation.
abstract class Pool<T> {
  int _index = 0;

  /// The maximum number of objects that will be pooled.
  final int max;

  /// The highest number of free objects. Can be reset any time.
  int peak = 0;

  final List<T> _freeObjects;

  /**
   * Creates a pool with the specified initial capacity and a maximum number of
   * free objects to store in this pool.
   */
  Pool([int initialCapacity = 16, int max = 0x7FFFFFFF])
      : _freeObjects = new List<T>(),
        this.max = max {
    _freeObjects.length = initialCapacity;
  }

  T newObject();

  /**
   * Returns an object from this pool. The object may be new (from [newObject])
   * or reused (previously freed with [free].
   */
  T obtain() {
    if (_index == 0) return newObject();
    return _freeObjects.removeAt(--_index);
  }

  /**
   * Puts the specified object in the pool, making it eligible to be returned by
   * [obtain]. If the pool already contains [max] free objects, the specified
   * object is reset but not added to the pool.
   */
  void free(T object) {
    if (object == null) throw new ArgumentError('object cannot be null.');

    if (_freeObjects.length < max) {
      if (_index >= _freeObjects.length) _freeObjects.length += 16;
      _freeObjects[_index++] = object;
      peak = math.max(peak, _freeObjects.length);
    }

    if (object is Poolable) (object as Poolable).reset();
  }

  /**
   * Puts the specified objects in the pool. Null objects within the array are
   * silently ignored.
   */
  void freeAll(List<T> objects) {
    if (objects == null) throw new ArgumentError('object cannot be null.');

    for (var object in objects) {
      if (object == null) continue;

      if (_freeObjects.length < max) {
        if (_index >= _freeObjects.length) _freeObjects.length += 16;
        _freeObjects[_index++] = object;
      }

      if (object is Poolable) (object as Poolable).reset();
    }

    peak = math.max(peak, _freeObjects.length);
  }

  /// Removes all free objects from this pool.
  void clear() {
    _index = 0;
    _freeObjects.clear();
  }

  /// The number of objects available to be obtained.
  int get getFree => _index;
}
