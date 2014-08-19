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
class AtlasReader {
  int _index = 0;
  List<String> _lines;

  AtlasReader(String text) {
    _lines = text.split(new RegExp(r'\r\n|\r|\n'));
  }

  String readLine() {
    if (_index >= _lines.length) return null;
    return _lines[_index++];
  }

  String readValue() {
    var line = readLine();
    int colon = line.indexOf(':');

    if (colon == -1) throw 'Invalid line: $line';

    return line.substring(colon + 1).trim();
  }

  /// Returns the number of tuple values read (1, 2 or 4).
  int readTuple(List<String> tuple) {
    var line = readLine();
    int colon = line.indexOf(':');

    if (colon == -1) throw 'Invalid line: $line';

    int i = 0,
        lastMatch = colon + 1;

    for ( ; i < 3; i++) {
      int comma = line.indexOf(',', lastMatch);

      if (comma == -1) break;

      tuple[i] = line.substring(lastMatch, comma).trim();
      lastMatch = comma + 1;
    }

    tuple[i] = line.substring(lastMatch).trim();

    return i + 1;
  }
}
