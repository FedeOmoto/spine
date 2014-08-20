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

/**
 * A Dart implementation of the Esoteric Software [Spine](http://
 * esotericsoftware.com/) runtime.
 */
library spine;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:async';

import 'package:path/path.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

part 'src/utils/color.dart';
part 'src/utils/poolable.dart';
part 'src/utils/pool.dart';
part 'src/utils/enum.dart';
part 'src/utils/point.dart';
part 'src/animation/timeline.dart';
part 'src/animation/curve_timeline.dart';
part 'src/animation/rotate_timeline.dart';
part 'src/animation/translate_timeline.dart';
part 'src/animation/scale_timeline.dart';
part 'src/animation/color_timeline.dart';
part 'src/animation/attachment_timeline.dart';
part 'src/animation/event_timeline.dart';
part 'src/animation/draw_order_timeline.dart';
part 'src/animation/ffd_timeline.dart';
part 'src/animation/ik_constraint_timeline.dart';
part 'src/animation/animation.dart';
part 'src/animation_state_data/animation_state_data_key.dart';
part 'src/animation_state_data/animation_state_data.dart';
part 'src/animation_state/track_entry.dart';
part 'src/animation_state/track_entry_pool.dart';
part 'src/animation_state/animation_state_listener.dart';
part 'src/animation_state/animation_state_adapter.dart';
part 'src/animation_state/animation_state.dart';
part 'src/bone/bone_data.dart';
part 'src/bone/bone.dart';
part 'src/event/event_data.dart';
part 'src/event/event.dart';
part 'src/ik_constraint/ik_constraint_data.dart';
part 'src/ik_constraint/ik_constraint.dart';
part 'src/atlas/texture_loader.dart';
part 'src/atlas/atlas_page.dart';
part 'src/atlas/atlas_region.dart';
part 'src/atlas/atlas_reader.dart';
part 'src/atlas/atlas.dart';
part 'src/skeleton/polygon_pool.dart';
part 'src/skeleton/skeleton_bounds.dart';
part 'src/skeleton/skeleton_data.dart';
part 'src/skeleton/skeleton_json.dart';
part 'src/skeleton/skeleton.dart';
part 'src/skin/skin_key.dart';
part 'src/skin/skin.dart';
part 'src/slot/slot_data.dart';
part 'src/slot/slot.dart';
part 'src/attachments/attachment.dart';
part 'src/attachments/attachment_loader.dart';
part 'src/attachments/atlas_attachment_loader.dart';
part 'src/attachments/bounding_box_attachment.dart';
part 'src/attachments/mesh_attachment.dart';
part 'src/attachments/region_attachment.dart';
part 'src/attachments/region_sequence_attachment.dart';
part 'src/attachments/skeleton_attachment.dart';
part 'src/attachments/skinned_mesh_attachment.dart';

class TextureWrap<int> extends Enum<int> {
  const TextureWrap(int value) : super(value);

  static const TextureWrap mirroredRepeat = const TextureWrap(0);
  static const TextureWrap clampToEdge = const TextureWrap(1);
  static const TextureWrap repeat = const TextureWrap(2);
}

class Mode<int> extends Enum<int> {
  const Mode(int value) : super(value);

  static const Mode forward = const Mode(0);
  static const Mode backward = const Mode(1);
  static const Mode forwardLoop = const Mode(2);
  static const Mode backwardLoop = const Mode(3);
  static const Mode pingPong = const Mode(4);
  static const Mode random = const Mode(5);
}
