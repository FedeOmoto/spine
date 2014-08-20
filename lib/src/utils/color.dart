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

/**
 * A color class, holding the r, g, b and alpha component as floats in the range
 * [0,1]. All methods perform clamping on the internal values after execution.
 */
class Color {
  /**
   * Encodes the ABGR int color as a float. The high bits are masked to avoid
   * using floats in the NaN range, which unfortunately means the full range of
   * alpha cannot be used.
   */
  static double intToFloatColor(int value) {
    ByteData bd = new ByteData(4);
    bd.setInt32(0, value & 0xfeffffff); // TODO: is the mask really needed?

    return bd.getFloat32(0);
  }

  double _r, _g, _b, _a;

  /// Constructor, sets the components of the color.
  Color(double red, double green, double blue, double alpha) {
    setValues(red, green, blue, alpha);
  }

  /// Constructs a new color using the given color.
  Color.from(Color other) {
    _r = other._r;
    _g = other._g;
    _b = other._b;
    _a = other._a;
  }

  /// Constructs a new color from a float.
  Color.fromFloat(double value) {
    ByteData bd = new ByteData(4);
    bd.setFloat32(0, value);

    _r = bd.getUint8(0) / 255;
    _g = bd.getUint8(1) / 255;
    _b = bd.getUint8(2) / 255;
    _a = bd.getUint8(3) / 255;
  }

  /// Returns a new color from a hex string with the format RRGGBBAA.
  Color.hex(String hex) {
    int r = int.parse(hex.substring(0, 2), radix: 16, onError: _onFormatError);
    int g = int.parse(hex.substring(2, 4), radix: 16, onError: _onFormatError);
    int b = int.parse(hex.substring(4, 6), radix: 16, onError: _onFormatError);
    int a = int.parse(hex.substring(6, 8), radix: 16, onError: _onFormatError);

    _r = r / 255;
    _g = g / 255;
    _b = b / 255;
    _a = a / 255;
  }

  int _onFormatError(String source) {
    throw new FormatException('Bad hexadecimal value');
  }

  /// Returns the red component.
  double get r => _r;

  /// Sets the red component.
  void set r(double value) {
    _r = value.clamp(0.0, 1.0);
  }

  /// Returns the green component.
  double get g => _g;

  /// Sets the green component.
  void set g(double value) {
    _g = value.clamp(0.0, 1.0);
  }

  /// Returns the blue component.
  double get b => _b;

  /// Sets the blue component.
  void set b(double value) {
    _b = value.clamp(0.0, 1.0);
  }

  /// Returns the alpha component.
  double get a => _a;

  /// Sets the alpha component.
  void set a(double value) {
    _a = value.clamp(0.0, 1.0);
  }

  /// Adds the given color component values to this [Color]'s values.
  void add(double r, double g, double b, double a) {
    _r = (r + _r).clamp(0.0, 1.0);
    _g = (g + _g).clamp(0.0, 1.0);
    _b = (b + _b).clamp(0.0, 1.0);
    _a = (a + _a).clamp(0.0, 1.0);
  }

  /// Sets this [Color] to the given color.
  void set(Color other) {
    _r = other._r;
    _g = other._g;
    _b = other._b;
    _a = other._a;
  }

  /// Sets this [Color]'s component values.
  void setValues(double r, double g, double b, double a) {
    _r = r.clamp(0.0, 1.0);
    _g = g.clamp(0.0, 1.0);
    _b = b.clamp(0.0, 1.0);
    _a = a.clamp(0.0, 1.0);
  }

  /// Packs the color components into a 32-bit integer with the format RGB.
  int toIntBits() {
    ByteData bd = new ByteData(4);
    bd.setInt8(0, 0);
    bd.setInt8(1, (_r * 255).toInt());
    bd.setInt8(2, (_g * 255).toInt());
    bd.setInt8(3, (_b * 255).toInt());

    return bd.getInt32(0);
  }
}
