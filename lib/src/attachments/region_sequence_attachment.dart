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

/// Attachment that displays various texture regions over time.
class RegionSequenceAttachment extends RegionAttachment {
  Mode<int> _mode;
  double _frameTime;
  List<AtlasRegion> _regions;
  math.Random _random = new math.Random();

  RegionSequenceAttachment(String name) : super(name);

  void updateWorldVertices(Slot slot, bool premultipliedAlpha) {
    if (_regions == null) throw new StateError(
        'Regions have not been set: $this');

    int frameIndex = (slot.attachmentTime / _frameTime).truncate();

    switch (_mode) {
      case Mode.forward:
        frameIndex = math.min(_regions.length - 1, frameIndex);
        break;

      case Mode.forwardLoop:
        frameIndex = frameIndex % _regions.length;
        break;

      case Mode.pingPong:
        frameIndex = frameIndex % (_regions.length * 2);

        if (frameIndex >= _regions.length) {
          frameIndex = _regions.length - 1 - (frameIndex - _regions.length);
        }

        break;

      case Mode.random:
        frameIndex = _random.nextInt(_regions.length);
        break;

      case Mode.backward:
        frameIndex = math.max(_regions.length - frameIndex - 1, 0);
        break;

      case Mode.backwardLoop:
        frameIndex = frameIndex % _regions.length;
        frameIndex = _regions.length - frameIndex - 1;
        break;
    }

    region = _regions[frameIndex];

    super.updateWorldVertices(slot, premultipliedAlpha);
  }

  List<AtlasRegion> get regions {
    if (_regions == null) throw new StateError(
        'Regions have not been set: $this');
    return _regions;
  }

  void set regions(List<AtlasRegion> regions) {
    _regions = regions;
  }

  /// Sets the time in seconds each frame is shown.
  void set frameTime(double frameTime) {
    _frameTime = frameTime;
  }

  void set mode(Mode mode) {
    _mode = mode;
  }
}
