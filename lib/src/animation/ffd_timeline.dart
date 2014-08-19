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
class FfdTimeline extends CurveTimeline {
  // time, ...
  final List<double> _frames;

  final List<List<double>> _frameVertices;
  int slotIndex;
  Attachment attachment;

  FfdTimeline(int frameCount)
      : _frames = new List<double>(frameCount),
        _frameVertices = new List<List<double>>(frameCount),
        super(frameCount);

  List<double> get getFrames => _frames;

  List<List<double>> get getVertices => _frameVertices;

  /// Sets the time of the specified keyframe.
  void setFrame(int frameIndex, double time, List<double> vertices) {
    _frames[frameIndex] = time;
    _frameVertices[frameIndex] = vertices;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event>
      firedEvents, double alpha) {
    var slot = skeleton.slots[slotIndex];

    if (slot.attachment != attachment) return;

    // Time is before first frame.
    if (time < _frames.first) return;

    int vertexCount = _frameVertices.first.length;

    var vertices = slot.attachmentVertices;

    // Don't mix from uninitialized slot vertices.
    if (vertices.length != vertexCount) alpha = 1.0;

    if (vertices.length < vertexCount) vertices.length = vertexCount;

    // Time is after last frame.
    if (time >= _frames.last) {
      var lastVertices = _frameVertices[_frames.length - 1];

      if (alpha < 1) {
        for (int i = 0; i < vertexCount; i++) {
          vertices[i] += (lastVertices[i] - vertices[i]) * alpha;
        }
      } else {
        vertices.setAll(0, lastVertices.map((e) => e.toDouble()).take(
            vertexCount));
      }

      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = Animation.binarySearch(_frames, time);
    double frameTime = _frames[frameIndex];
    double percent = (1 - (time - frameTime) / (_frames[frameIndex - 1] -
        frameTime)).clamp(0.0, 1.0);
    percent = getCurvePercent(frameIndex - 1, percent);

    var prevVertices = _frameVertices[frameIndex - 1];
    var nextVertices = _frameVertices[frameIndex];

    if (alpha < 1) {
      for (int i = 0; i < vertexCount; i++) {
        double prev = prevVertices[i];
        vertices[i] += (prev + (nextVertices[i] - prev) * percent - vertices[i])
            * alpha;
      }
    } else {
      for (int i = 0; i < vertexCount; i++) {
        num prev = prevVertices[i];
        vertices[i] = prev + (nextVertices[i] - prev) * percent;
      }
    }
  }
}
