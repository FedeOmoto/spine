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
 * Loads images from texture atlases created by [TexturePacker](https://
 * www.codeandweb.com/texturepacker).
 * Texture atlases must be [dispose]d to free up the resources consumed by the
 * backing textures.
 */
class Atlas {
  static const Map<String, int> FORMAT = const {
    'alpha': 0,
    'intensity': 1,
    'luminanceAlpha': 2,
    'rgb565': 3,
    'rgba4444': 4,
    'rgb888': 5,
    'rgba8888': 6
  };

  static const Map<String, int> TEXTURE_FILTER = const {
    'nearest': 0,
    'linear': 1,
    'mipMap': 2,
    'mipMapNearestNearest': 3,
    'mipMapLinearNearest': 4,
    'mipMapNearestLinear': 5,
    'mipMapLinearLinear': 6
  };

  final TextureLoader textureLoader;
  final List<AtlasPage> pages = new List<AtlasPage>();
  final List<AtlasRegion> regions = new List<AtlasRegion>();

  StreamController<Atlas> _streamController = new StreamController.broadcast(
      sync: true);

  Atlas(String atlasText, this.textureLoader) {
    var reader = new AtlasReader(atlasText);

    _load(reader);
  }

  void _load(AtlasReader atlasReader, [AtlasPage atlasPage]) {
    AtlasPage page = atlasPage;

    while (true) {
      var line = atlasReader.readLine();

      if (line == null) {
        _streamController.add(this);
        break;
      }

      line = line.trim();

      if (line.isEmpty) {
        page = null;
      } else if (page == null) {
        page = new AtlasPage();
        page.name = line;

        _loadPage(page, atlasReader);

        break;
      } else {
        var region = new AtlasRegion();

        region.name = line;
        region.page = page;

        _loadRegion(region, atlasReader);
      }
    }
  }

  void _loadPage(AtlasPage page, AtlasReader reader) {
    var tuple = new List<String>(4);

    // Size is only optional for an atlas packed with an old TexturePacker.
    if (reader.readTuple(tuple) == 2) {
      page.width = int.parse(tuple[0]);
      page.height = int.parse(tuple[1]);
      reader.readTuple(tuple);
    }

    page.format = FORMAT[tuple[0]];

    reader.readTuple(tuple);
    page.minFilter = TEXTURE_FILTER[tuple[0]];
    page.magFilter = TEXTURE_FILTER[tuple[1]];

    var direction = reader.readValue();

    page.uWrap = TextureWrap.clampToEdge;
    page.vWrap = TextureWrap.clampToEdge;

    if (direction == 'x') {
      page.uWrap = TextureWrap.repeat;
    } else if (direction == 'y') {
      page.vWrap = TextureWrap.repeat;
    } else if (direction == 'xy') {
      page.uWrap = page.vWrap = TextureWrap.repeat;
    }

    textureLoader.onLoaded.listen((page) {
      pages.add(page);
      _load(reader, page);
    });

    textureLoader.load(page, page.name, this);
  }

  void _loadRegion(AtlasRegion region, AtlasReader reader) {
    var page = region.page;
    var tuple = new List<String>(4);

    region.rotate = reader.readValue() == 'true';

    reader.readTuple(tuple);

    var x = int.parse(tuple[0]);
    var y = int.parse(tuple[1]);

    reader.readTuple(tuple);

    var width = int.parse(tuple[0]);
    var height = int.parse(tuple[1]);

    region.u = x / page.width;
    region.v = y / page.height;

    if (region.rotate) {
      region.u2 = (x + height) / page.width;
      region.v2 = (y + width) / page.height;
    } else {
      region.u2 = (x + width) / page.width;
      region.v2 = (y + height) / page.height;
    }

    region.x = x;
    region.y = y;
    region.width = width.abs();
    region.height = height.abs();
    region.packedWidth = region.width;
    region.packedHeight = region.height;

    if (reader.readTuple(tuple) == 4) {
      // Split is optional.
      region.splits = [int.parse(tuple[0]), int.parse(tuple[1]), int.parse(
          tuple[2]), int.parse(tuple[3])];

      if (reader.readTuple(tuple) == 4) {
        // Pad is optional, but only present with splits.
        region.pads = [int.parse(tuple[0]), int.parse(tuple[1]), int.parse(
            tuple[2]), int.parse(tuple[3])];

        reader.readTuple(tuple);
      }
    }

    region.originalWidth = int.parse(tuple[0]);
    region.originalHeight = int.parse(tuple[1]);

    reader.readTuple(tuple);
    region.offsetX = double.parse(tuple[0]);
    region.offsetY = double.parse(tuple[1]);

    region.index = int.parse(reader.readValue());

    regions.add(region);
  }

  /**
   * Returns the first region found with the specified name. This method uses
   * string comparison to find the region, so the result should be cached rather
   * than calling this method multiple times.
   */
  AtlasRegion findRegion(String name) {
    for (var region in regions) {
      if (region.name == name) return region;
    }

    return null;
  }

  /**
   * Releases all resources associated with this [Atlas] instance. This releases
   * all the textures backing all [AtlasRegion]s, which should no longer be used
   * after calling dispose.
   */
  void dispose() {
    pages.forEach((page) => textureLoader.unload(page.rendererObject));
  }

  void updateUVs(AtlasPage page) {
    for (var region in regions) {
      if (region.page != page) continue;

      region.u = region.x / page.width;
      region.v = region.y / page.height;

      if (region.rotate) {
        region.u2 = (region.x + region.height) / page.width;
        region.v2 = (region.y + region.width) / page.height;
      } else {
        region.u2 = (region.x + region.width) / page.width;
        region.v2 = (region.y + region.height) / page.height;
      }
    }
  }

  /// Stream of `loaded` events handled by this [Atlas].
  Stream<Atlas> get onLoaded => _streamController.stream;
}
