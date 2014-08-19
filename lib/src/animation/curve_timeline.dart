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
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.e.

part of spine;

/// Base class for frames that use an interpolation bezier curve.
abstract class CurveTimeline implements Timeline {
  static const double LINEAR = 0.0,
      STEPPED = 1.0,
      BEZIER = 2.0;
  static const int _BEZIER_SEGMENTS = 10,
      _BEZIER_SIZE = _BEZIER_SEGMENTS * 2 - 1;

  final List<double> _curves;

  CurveTimeline(int frameCount) : _curves = new List<double>.filled((frameCount
      - 1) * _BEZIER_SIZE, 0.0);

  int get getFrameCount => (_curves.length / _BEZIER_SIZE + 1).toInt();

  void setLinear(int frameIndex) {
    _curves[frameIndex * _BEZIER_SIZE] = LINEAR;
  }

  void setStepped(int frameIndex) {
    _curves[frameIndex * _BEZIER_SIZE] = STEPPED;
  }

  double getCurveType(int frameIndex) {
    int index = frameIndex * _BEZIER_SIZE;
    if (index == _curves.length) return LINEAR;
    double type = _curves[index];
    if (type == LINEAR) return LINEAR;
    if (type == STEPPED) return STEPPED;
    return BEZIER;
  }

  /**
   * Sets the control handle positions for an interpolation bezier curve used to
   * transition from this keyframe to the next.
   * cx1 and cx2 are from 0 to 1, representing the percent of time between the
   * two keyframes. cy1 and cy2 are the percent of the difference between the
   * keyframe's values.
   */
  void setCurve(int frameIndex, double cx1, double cy1, double cx2, double cy2)
      {
    double subdiv1 = 1.0 / _BEZIER_SEGMENTS,
        subdiv2 = subdiv1 * subdiv1,
        subdiv3 = subdiv2 * subdiv1;

    double pre1 = 3 * subdiv1,
        pre2 = 3 * subdiv2,
        pre4 = 6 * subdiv2,
        pre5 = 6 * subdiv3;

    double tmp1x = -cx1 * 2 + cx2,
        tmp1y = -cy1 * 2 + cy2,
        tmp2x = (cx1 - cx2) * 3 + 1,
        tmp2y = (cy1 - cy2) * 3 + 1;

    double dfx = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv3,
        dfy = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv3;

    double ddfx = tmp1x * pre4 + tmp2x * pre5,
        ddfy = tmp1y * pre4 + tmp2y * pre5;

    double dddfx = tmp2x * pre5,
        dddfy = tmp2y * pre5;

    int i = frameIndex * _BEZIER_SIZE;
    _curves[i++] = BEZIER;

    double x = dfx,
        y = dfy;

    for (int n = i + _BEZIER_SIZE - 1; i < n; i += 2) {
      _curves[i] = x;
      _curves[i + 1] = y;
      dfx += ddfx;
      dfy += ddfy;
      ddfx += dddfx;
      ddfy += dddfy;
      x += dfx;
      y += dfy;
    }
  }

  double getCurvePercent(int frameIndex, double percent) {
    int i = frameIndex * _BEZIER_SIZE;
    double type = _curves[i];

    if (type == LINEAR) return percent;
    if (type == STEPPED) return 0.0;

    i++;
    double x = 0.0;

    for (int start = i,
        n = i + _BEZIER_SIZE - 1; i < n; i += 2) {
      x = _curves[i];

      if (x >= percent) {
        double prevX, prevY;

        if (i == start) {
          prevX = 0.0;
          prevY = 0.0;
        } else {
          prevX = _curves[i - 2];
          prevY = _curves[i - 1];
        }

        return prevY + (_curves[i + 1] - prevY) * (percent - prevX) / (x -
            prevX);
      }
    }

    double y = _curves[i - 1];

    return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
  }
}
