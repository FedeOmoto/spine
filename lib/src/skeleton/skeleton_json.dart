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
class SkeletonJson {
  static const Map<String, int> ATTACHMENT_TYPE = const {
    'region': 0,
    'boundingbox': 1,
    'mesh': 2,
    'skinnedmesh': 3
  };

  final AttachmentLoader _attachmentLoader;
  double scale = 1.0;

  SkeletonJson.fromAtlas(Atlas atlas) : _attachmentLoader =
      new AtlasAttachmentLoader(atlas);

  SkeletonJson(this._attachmentLoader);

  SkeletonData readSkeletonData(Map<String, dynamic> root, String name) {
    var skeletonData = new SkeletonData();
    skeletonData.name = withoutExtension(name);

    // Skeleton.
    Map<String, dynamic> skeletonMap = root['skeleton'];

    if (skeletonMap != null) {
      skeletonData.version = skeletonMap['spine'];
      skeletonData.hash = skeletonMap['hash'];
      skeletonData.width = skeletonMap['width'].toDouble();
      skeletonData.height = skeletonMap['height'].toDouble();
    }

    // Bones.
    (root['bones'] as List<Map<String, dynamic>>).forEach((boneMap) {
      var parent;
      var parentName = boneMap['parent'];

      if (parentName != null) {
        parent = skeletonData.findBone(parentName);
        if (parent == null) throw 'Parent bone not found: $parentName';
      }

      var value;

      var boneData = new BoneData(boneMap['name'], parent);
      boneData.length = ((value = boneMap['length']) == null ? 0.0 : value) *
          scale;
      boneData.x = ((value = boneMap['x']) == null ? 0.0 : value) * scale;
      boneData.y = ((value = boneMap['y']) == null ? 0.0 : value) * scale;
      boneData.rotation = (value = boneMap['rotation']) == null ? 0.0 :
          value.toDouble();
      boneData.scaleX = (value = boneMap['scaleX']) == null ? 1.0 :
          value.toDouble();
      boneData.scaleY = (value = boneMap['scaleY']) == null ? 1.0 :
          value.toDouble();
      boneData.inheritScale = (value = boneMap['inheritScale']) == null ? true :
          value;
      boneData.inheritRotation = (value = boneMap['inheritRotation']) == null ?
          true : value;

      var color = boneMap['color'];

      if (color != null) boneData.color.set(new Color.hex(color));

      skeletonData.bones.add(boneData);
    });

    // IK.
    var ik = root['ik'];

    if (ik != null) {
      (ik as List<Map<String, dynamic>>).forEach((ikMap) {
        IkConstraintData ikConstraintData = new IkConstraintData(ikMap['name']);

        (ikMap['bones'] as List).forEach((boneList) {
          var boneName = boneList.toString();
          var bone = skeletonData.findBone(boneName);
          if (bone == null) throw 'IK bone not found: $boneName';
          ikConstraintData.bones.add(bone);
        });

        var targetName = ikMap['target'];

        ikConstraintData.target = skeletonData.findBone(targetName);
        if (ikConstraintData.target == null) throw
            'Target bone not found: $targetName';

        var value;

        ikConstraintData.bendDirection = ((value = ikMap['bendPositive']) ==
            null ? true : value) ? 1 : -1;
        ikConstraintData.mix = (value = ikMap['mix']) == null ? 1.0 :
            value.toDouble();

        skeletonData.ikConstraints.add(ikConstraintData);
      });
    }

    // Slots.
    (root['slots'] as List<Map<String, dynamic>>).forEach((slotMap) {
      var slotName = slotMap['name'];
      var boneName = slotMap['bone'];
      var boneData = skeletonData.findBone(boneName);

      if (boneData == null) throw 'Slot bone not found: $boneName';

      var slotData = new SlotData(slotName, boneData);

      var color = slotMap['color'];

      if (color != null) slotData.color.set(new Color.hex(color));

      slotData.attachmentName = slotMap['attachment'];

      bool value;
      slotData.additiveBlending = (value = slotMap['additive']) == null ? false
          : value;

      skeletonData.slots.add(slotData);
    });

    // Skins.
    (root['skins'] as Map<String, Map>).forEach((skinMapName, skinMapChild) {
      var skin = new Skin(skinMapName);

      (skinMapChild as Map<String, Map>).forEach((slotEntryName, slotEntryChild)
          {
        int slotIndex = skeletonData.findSlotIndex(slotEntryName);

        if (slotIndex == -1) throw 'Slot not found: $slotEntryName';

        (slotEntryChild as Map<String, Map>).forEach((entryName, entryChild) {
          var attachment = _readAttachment(skin, entryName, entryChild);
          if (attachment != null) skin.addAttachment(slotIndex, entryName,
              attachment);
        });
      });

      skeletonData.skins.add(skin);
      if (skin.name == 'default') skeletonData.defaultSkin = skin;
    });

    // Events.
    var events = root['events'];

    if (events != null) {
      (events as Map<String, Map>).forEach((eventMapName, eventMapChild) {
        var value;

        var eventData = new EventData(eventMapName);
        eventData.intValue = (value = eventMapChild['int']) == null ? 0 : value;
        eventData.floatValue = (value = eventMapChild['float']) == null ? 0.0 :
            value.toDouble();
        eventData.stringValue = eventMapChild['string'];
        skeletonData.events.add(eventData);
      });
    }

    // Animations.
    (root['animations'] as Map<String, Map>).forEach(
        (animationMapName, animationMapChild) {
      _readAnimation(animationMapName, animationMapChild, skeletonData);
    });

    return skeletonData;
  }

  Attachment _readAttachment(Skin skin, String name, Map<String, dynamic> map) {
    var value;
    name = (value = map['name']) == null ? name : value;
    var path = (value = map['path']) == null ? name : value;

    switch (ATTACHMENT_TYPE[(value = map['type']) == null ? 'region' : value]) {
      // region.
      case 0:
        var region = _attachmentLoader.newRegionAttachment(skin, name, path);

        if (region == null) return null;

        region.path = path;
        region.x = ((value = map['x']) == null ? 0.0 : value) * scale;
        region.y = ((value = map['y']) == null ? 0.0 : value) * scale;
        region.scaleX = (value = map['scaleX']) == null ? 1.0 : value.toDouble(
            );
        region.scaleY = (value = map['scaleY']) == null ? 1.0 : value.toDouble(
            );
        region.rotation = (value = map['rotation']) == null ? 0.0 :
            value.toDouble();
        region.width = map['width'] * scale;
        region.height = map['height'] * scale;

        var color = map['color'];

        if (color != null) region.getColor.set(new Color.hex(color));

        region.updateOffset();

        return region;

      // boundingbox.
      case 1:
        var box = _attachmentLoader.newBoundingBoxAttachment(skin, name);

        if (box == null) return null;

        var vertices = map['vertices'];

        if (scale != 1) {
          for (int i = 0,
              n = vertices.length; i < n; i++) {
            vertices[i] *= scale;
          }
        }

        box.vertices = vertices;

        return box;

      // mesh.
      case 2:
        var value;
        var mesh = _attachmentLoader.newMeshAttachment(skin, name, path);

        if (mesh == null) return null;

        mesh.path = path;

        var vertices = map['vertices'];

        if (scale != 1) {
          for (int i = 0,
              n = vertices.length; i < n; i++) {
            vertices[i] *= scale;
          }
        }

        mesh.vertices = vertices;
        mesh.triangles = map['triangles'];
        mesh.regionUVs = map['uvs'];
        mesh.updateUVs();

        if (map.containsKey('hull')) mesh.hullLength = map['hull'] * 2;
        if (map.containsKey('edges')) mesh.edges = map['edges'];
        mesh.width = ((value = map['width']) == null ? 0.0 : value) * scale;
        mesh.height = ((value = map['height']) == null ? 0.0 : value) * scale;

        return mesh;

      // skinnedmesh.
      case 3:
        var value;
        var mesh = _attachmentLoader.newSkinnedMeshAttachment(skin, name, path);

        if (mesh == null) return null;

        mesh.path = path;

        var uvs = map['uvs'];
        var vertices = map['vertices'];
        var weights = new List<double>();
        var bones = new List<int>();

        for (int i = 0,
            n = vertices.length; i < n; ) {
          int boneCount = vertices[i++].truncate();

          bones.add(boneCount);

          for (int nn = i + boneCount * 4; i < nn; ) {
            bones.add(vertices[i].truncate());
            weights.add(vertices[i + 1] * scale);
            weights.add(vertices[i + 2] * scale);
            weights.add(vertices[i + 3].toDouble());
            i += 4;
          }
        }

        mesh.bones = bones;
        mesh.weights = weights;
        mesh.triangles = map['triangles'];
        mesh.regionUVs = uvs;
        mesh.updateUVs();

        if (map.containsKey('hull')) mesh.hullLength = map['hull'] * 2;
        if (map.containsKey('edges')) mesh.edges = map['edges'];
        mesh.width = ((value = map['width']) == null ? 0.0 : value) * scale;
        mesh.height = ((value = map['height']) == null ? 0.0 : value) * scale;

        return mesh;
    }

    return null;
  }

  void _readAnimation(String name, dynamic map, SkeletonData skeletonData) {
    List<Timeline> timelines = new List<Timeline>();
    double duration = 0.0;

    // Slot timelines.
    var slots = map['slots'];

    if (slots != null) {
      (map['slots'] as Map<String, Map>).forEach((slotMapName, slotMapChild) {
        int slotIndex = skeletonData.findSlotIndex(slotMapName);

        if (slotIndex == -1) throw 'Slot not found: $slotMapName';

        (slotMapChild as Map<String, List>).forEach(
            (timelineMapName, timelineMapChild) {
          var timelineName = timelineMapName;

          if (timelineName == 'color') {
            var timeline = new ColorTimeline(timelineMapChild.length);
            timeline.slotIndex = slotIndex;

            int frameIndex = 0;

            (timelineMapChild as List<Map<String, dynamic>>).forEach((valueMap)
                {
              var color = new Color.hex(valueMap['color']);

              timeline.setFrame(frameIndex, valueMap['time'].toDouble(),
                  color.r, color.g, color.b, color.a);
              _readCurve(timeline, frameIndex, valueMap);
              frameIndex++;
            });

            timelines.add(timeline);
            duration = math.max(duration,
                timeline.getFrames[timeline.getFrameCount * 5 - 5]);
          } else if (timelineName == 'attachment') {
            var timeline = new AttachmentTimeline(timelineMapChild.length);
            timeline.slotIndex = slotIndex;

            int frameIndex = 0;

            (timelineMapChild as List<Map<String, dynamic>>).forEach((valueMap)
                {
              timeline.setFrame(frameIndex++, valueMap['time'].toDouble(),
                  valueMap['name']);
            });

            timelines.add(timeline);
            duration = math.max(duration,
                timeline.getFrames[timeline.getFrameCount - 1]);
          } else {
            throw
                'Invalid timeline type for a slot: $timelineName ($slotMapName)';
          }
        });
      });
    }

    // Bone timelines.
    (map['bones'] as Map<String, Map>).forEach((boneMapName, boneMapChild) {
      int boneIndex = skeletonData.findBoneIndex(boneMapName);

      if (boneIndex == -1) throw 'Bone not found: $boneMapName';

      (boneMapChild as Map<String, List>).forEach(
          (timelineMapName, timelineMapChild) {
        var timelineName = timelineMapName;

        if (timelineName == 'rotate') {
          var timeline = new RotateTimeline(timelineMapChild.length);
          timeline.boneIndex = boneIndex;

          int frameIndex = 0;

          (timelineMapChild as List<Map<String, dynamic>>).forEach((valueMap) {
            timeline.setFrame(frameIndex, valueMap['time'].toDouble(),
                valueMap['angle'].toDouble());
            _readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          });

          timelines.add(timeline);
          duration = math.max(duration,
              timeline.getFrames[timeline.getFrameCount * 2 - 2]);
        } else if (timelineName == 'translate' || timelineName == 'scale') {
          TranslateTimeline timeline;
          double timelineScale = 1.0;

          if (timelineName == 'scale') {
            timeline = new ScaleTimeline(timelineMapChild.length);
          } else {
            timeline = new TranslateTimeline(timelineMapChild.length);
            timelineScale = scale;
          }

          timeline.boneIndex = boneIndex;

          int frameIndex = 0;

          var value;

          (timelineMapChild as List<Map<String, dynamic>>).forEach((valueMap) {
            double x = ((value = valueMap['x']) == null ? 0.0 : value.toDouble(
                ));
            double y = ((value = valueMap['y']) == null ? 0.0 : value.toDouble(
                ));
            timeline.setFrame(frameIndex, valueMap['time'].toDouble(), x *
                timelineScale, y * timelineScale);
            _readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          });

          timelines.add(timeline);
          duration = math.max(duration,
              timeline.getFrames[timeline.getFrameCount * 3 - 3]);

        } else {
          throw
              'Invalid timeline type for a bone: $timelineName ($boneMapName)';
        }
      });
    });

    // FFD timelines.
    var ffd = map['ffd'];

    if (ffd != null) {
      (map['ffd'] as Map<String, Map>).forEach((ffdMapName, ffdMapChild) {
        var skin = skeletonData.findSkin(ffdMapName);

        if (skin == null) throw 'Skin not found: $ffdMapName';

        (ffdMapChild as Map<String, Map>).forEach((slotMapName, slotMapChild) {
          int slotIndex = skeletonData.findSlotIndex(slotMapName);

          if (slotIndex == -1) throw 'Slot not found: $slotMapName';

          (slotMapChild as Map<String, List>).forEach(
              (meshMapName, meshMapChild) {
            var timeline = new FfdTimeline(meshMapChild.length);
            var attachment = skin.getAttachment(slotIndex, meshMapName);

            if (attachment == null) throw
                'FFD attachment not found: $meshMapName';

            timeline.slotIndex = slotIndex;
            timeline.attachment = attachment;

            int vertexCount;

            if (attachment is MeshAttachment) {
              vertexCount = (attachment as MeshAttachment).vertices.length;
            } else {
              vertexCount = ((attachment as
                  SkinnedMeshAttachment).weights.length / 3 * 2).toInt();
            }

            int frameIndex = 0;

            (meshMapChild as List<Map<String, dynamic>>).forEach((valueMap) {
              var vertices;
              var verticesValue = valueMap['vertices'];

              if (verticesValue == null) {
                if (attachment is MeshAttachment) {
                  vertices = (attachment as MeshAttachment).vertices;
                } else {
                  vertices = new List<double>.filled(vertexCount, 0.0);
                }
              } else {
                vertices = new List<double>.filled(vertexCount, 0.0);
                int offset = valueMap['offset'];
                int start = offset == null ? 0 : offset;

                vertices.setAll(0, verticesValue.map((e) => e.toDouble()).take(
                    verticesValue.length));

                if (scale != 1) {
                  for (int i = start,
                      n = i + verticesValue.size; i < n; i++) {
                    vertices[i] *= scale;
                  }
                }

                if (attachment is MeshAttachment) {
                  var meshVertices = (attachment as MeshAttachment).vertices;
                  for (int i = 0; i < vertexCount; i++) {
                    vertices[i] += meshVertices[i];
                  }
                }
              }

              timeline.setFrame(frameIndex, valueMap['time'].toDouble(),
                  vertices);
              _readCurve(timeline, frameIndex, valueMap);
              frameIndex++;
            });

            timelines.add(timeline);
            duration = math.max(duration,
                timeline.getFrames[timeline.getFrameCount - 1]);
          });
        });
      });
    }

    // Draw order timeline.
    var drawOrdersMap = map['draworder'] as List<Map<String, dynamic>>;

    if (drawOrdersMap != null) {
      var timeline = new DrawOrderTimeline(drawOrdersMap.length);
      int slotCount = skeletonData.slots.length;
      int frameIndex = 0;

      drawOrdersMap.forEach((drawOrderMap) {
        var drawOrder;
        var offsets = drawOrderMap['offsets'];

        if (offsets != null) {
          drawOrder = new List<int>(slotCount);

          for (int i = slotCount - 1; i >= 0; i--) {
            drawOrder[i] = -1;
          }

          var unchanged = new List<int>(slotCount - offsets.length);
          int originalIndex = 0,
              unchangedIndex = 0;

          offsets.forEach((offsetMap) {
            int slotIndex = skeletonData.findSlotIndex(offsetMap['slot']);

            if (slotIndex == -1) throw 'Slot not found: ${offsetMap["slot"]}';

            // Collect unchanged items.
            while (originalIndex != slotIndex) {
              unchanged[unchangedIndex++] = originalIndex++;
            }

            // Set changed items.
            drawOrder[originalIndex + offsetMap['offset']] = originalIndex++;
          });

          // Collect remaining unchanged items.
          while (originalIndex < slotCount) {
            unchanged[unchangedIndex++] = originalIndex++;
          }

          // Fill in unchanged items.
          for (int i = slotCount - 1; i >= 0; i--) {
            if (drawOrder[i] == -1) drawOrder[i] = unchanged[--unchangedIndex];
          }
        }

        timeline.setFrame(frameIndex++, drawOrderMap['time'].toDouble(),
            drawOrder);
      });

      timelines.add(timeline);
      duration = math.max(duration, timeline.getFrames[timeline.getFrameCount -
          1]);
    }

    // Event timeline.
    var eventsMap = map['events'] as List<Map<String, dynamic>>;

    if (eventsMap != null) {
      var timeline = new EventTimeline(eventsMap.length);
      int frameIndex = 0;

      eventsMap.forEach((eventMap) {
        var eventData = skeletonData.findEvent(eventMap['name']);

        if (eventData == null) throw 'Event not found: ${eventMap["name"]}';

        var value;

        var event = new Event(eventData);
        event.intValue = ((value = eventMap['int']) == null ? eventData.intValue
            : value);
        event.floatValue = ((value = eventMap['float']) == null ?
            eventData.floatValue : value.toDouble());
        event.stringValue = ((value = eventMap['string']) == null ?
            eventData.stringValue : value);
        timeline.setFrame(frameIndex++, eventMap['time'].toDouble(), event);
      });

      timelines.add(timeline);
      duration = math.max(duration, timeline.getFrames[timeline.getFrameCount -
          1]);
    }

    skeletonData.animations.add(new Animation(name, timelines, duration));
  }

  void _readCurve(CurveTimeline timeline, int frameIndex, Map<String, dynamic>
      valueMap) {
    var curve = valueMap['curve'];

    if (curve == null) return;

    if (curve is String && curve == 'stepped') {
      timeline.setStepped(frameIndex);
    } else if (curve is List) {
      timeline.setCurve(frameIndex, curve[0].toDouble(), curve[1].toDouble(),
          curve[2].toDouble(), curve[3].toDouble());
    }
  }
}
