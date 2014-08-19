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
 * Describes the region of a packed image and provides information about the
 * original image before it was packed.
 */
class AtlasRegion {
  AtlasPage page;

  /// The name of the original image file, up to the first underscore.
  String name;

  int x, y, width, height;
  double u, v, u2, v2;

  /**
   * The offset from the left of the original image to the left of the packed
   * image, after whitespace was removed for packing.
   */
  double offsetX;

  /**
   * The offset from the bottom of the original image to the bottom of the
   * packed image, after whitespace was removed for packing.
   */
  double offsetY;

  /**
   * The width of the image, before whitespace was removed and rotation was
   * applied for packing.
   */
  int originalWidth;

  /// The height of the image, before whitespace was removed for packing.
  int originalHeight;

  /// The width of the image, after whitespace was removed for packing.
  int packedWidth;

  /// The height of the image, after whitespace was removed for packing.
  int packedHeight;

  /**
   * The number at the end of the original image file name, or -1 if none.
   * 
   * When sprites are packed, if the original file name ends with a number, it
   * is stored as the index and is not considered as part of the sprite's name.
   */
  int index;

  /// If true, the region has been rotated 90 degrees counter clockwise.
  bool rotate;

  /// The ninepatch splits, or null if not a ninepatch.
  List<int> splits;

  /// The ninepatch pads, or null if not a ninepatch or the has no padding.
  List<int> pads;
}
