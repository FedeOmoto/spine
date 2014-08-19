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
class BoneData {
  final BoneData parent;
  final String name;
  double length;
  double x, y;
  double rotation;
  double scaleX = 1.0,
      scaleY = 1.0;
  bool inheritScale = true,
      inheritRotation = true;

  // Nonessential.
  final Color color = new Color(0.61, 0.61, 0.61, 1.0);

  BoneData(this.name, [this.parent]) {
    if (name == null) throw new ArgumentError('name cannot be null.');
  }

  /// Copy constructor.
  BoneData.copy(BoneData bone, [this.parent]) : name = bone.name {
    if (bone == null) throw new ArgumentError('bone cannot be null.');
    length = bone.length;
    x = bone.x;
    y = bone.y;
    rotation = bone.rotation;
    scaleX = bone.scaleX;
    scaleY = bone.scaleY;
  }

  void set position(Point<double> value) {
    x = value.x;
    y = value.y;
  }

  void set scale(Point<double> value) {
    scaleX = value.x;
    scaleY = value.y;
  }

  @override
  String toString() => name;
}
