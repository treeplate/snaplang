import 'dart:math';

import 'package:flutter/rendering.dart';

import 'platform_detector_stub.dart'
    if (dart.library.io) 'dart:io'
    if (dart.library.js_interop) 'platform_detector_web.dart';
import 'package:download/download.dart';
import 'package:flutter/material.dart';
import 'structure.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Project project = Project(name: 'untitled');
  Scene get scene => project.scenes[project.currentScene];
  Sprite get sprite => scene.sprites[scene.currentSprite];
  static const double appBarHeight = 85;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: appBarHeight,
              title: Text(
                'TreeSnap: ${project.name}/${scene.name}/${sprite.name}',
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: SizedBox(
                          width: 200,
                          child: TextField(
                            onSubmitted: (text) {
                              setState(() {
                                project.name = text;
                              });
                              Navigator.pop(context);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
                DraggableScript(
                  script: null,
                  blockName: TextEditingController(),
                ),
                IconButton(
                  onPressed: () {
                    String dir;
                    if (Platform.isMacOS) {
                      dir = '../../../../Downloads/';
                    } else if (Platform.localeName == 'web') {
                      dir = '';
                    } else {
                      dir = 'not supported on this device/';
                    }
                    download(
                      Stream.fromIterable(
                        project.serialize().toXmlString(pretty: true).codeUnits,
                      ),
                      '$dir${project.name}.xml',
                    );
                  },
                  icon: Icon(Icons.download),
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Scene'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<int>(
                          value: project.currentScene,
                          items:
                              List.generate(
                                project.scenes.length,
                                (e) => DropdownMenuItem<int>(
                                  value: e,
                                  child: Text(project.scenes[e].name),
                                ),
                              ) +
                              [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('New scene'),
                                ),
                              ],
                          onChanged: (value) {
                            setState(() {
                              if (value == null) {
                                setState(() {
                                  project.currentScene = project.scenes.length;
                                  project.scenes.add(Scene(name: 'untitled'));
                                });
                              } else {
                                project.currentScene = value;
                              }
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                width: 200,
                                child: TextField(
                                  onSubmitted: (text) {
                                    setState(() {
                                      scene.name = text;
                                    });
                                    Navigator.pop(context);
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sprite'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<int>(
                          value: scene.currentSprite,
                          items:
                              List.generate(
                                scene.sprites.length,
                                (e) => DropdownMenuItem<int>(
                                  value: e,
                                  child: Text(scene.sprites[e].name),
                                ),
                              ) +
                              [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('New sprite'),
                                ),
                              ],
                          onChanged: (value) {
                            setState(() {
                              if (value == null) {
                                scene.currentSprite = scene.sprites.length;
                                scene.sprites.add(Sprite(name: 'untitled'));
                              } else {
                                scene.currentSprite = value;
                              }
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                width: 200,
                                child: TextField(
                                  onSubmitted: (text) {
                                    setState(() {
                                      sprite.name = text;
                                    });
                                    Navigator.pop(context);
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: DragTarget<(Script?, TextEditingController)>(
              onWillAcceptWithDetails: (details) {
                return true;
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  sprite.scripts.remove(details.data.$1);
                  sprite.scripts.add(
                    Script(
                      x: details.offset.dx,
                      y: details.offset.dy - appBarHeight,
                    )..blocks.add(Block(details.data.$2.text)),
                  );
                });
              },
              builder: (context, _, _) => SizedBox.expand(
                child: Stack(
                  children: [
                    ...sprite.scripts.map(
                      (e) => Positioned(
                        top: e.y,
                        left: e.x,
                        child: DraggableScript(
                          script: e,
                          blockName: TextEditingController(
                            text: e.blocks.single.name,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      theme: ThemeData.dark(),
    );
  }
}

class DraggableScript extends StatelessWidget {
  const DraggableScript({
    super.key,
    required this.blockName,
    required this.script,
  });

  final Script? script;
  final TextEditingController blockName;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: (script, blockName),
      feedback: ScriptWidget(blockName: blockName, script: script),
      childWhenDragging: Container(
        width: CommandShapeRenderBox.minWidth,
        height: CommandShapeRenderBox.minHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
      ),
      child: ScriptWidget(blockName: blockName, script: script),
    );
  }
}

class ScriptWidget extends StatefulWidget {
  const ScriptWidget({
    super.key,
    required this.blockName,
    required this.script,
  });

  final TextEditingController blockName;
  final Script? script;

  @override
  State<ScriptWidget> createState() => _ScriptWidgetState();
}

class _ScriptWidgetState extends State<ScriptWidget> {
  final ContextMenuController contextMenuController = ContextMenuController();

  @override
  Widget build(BuildContext context) {
    return CommandShapeWidget(
      color: Colors.orange,
      child: Material(
        child: SizedBox(
          height: 25,
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(offset: Offset(-1, -2), color: Colors.black45),
                ],
              ),
              child: TextField(
                controller: widget.blockName,
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                cursorHeight: 20,
                cursorWidth: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    gapPadding: 5,
                  ),
                  contentPadding: EdgeInsets.all(0),
                  fillColor: Colors.white,
                  filled: true,
                ),

                onChanged: (e) {
                  widget.script?.blocks.single.name = e;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommandShapeWidget extends SingleChildRenderObjectWidget {
  const CommandShapeWidget({super.key, super.child, required this.color});
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CommandShapeRenderBox(color: color);
  }
}

class CommandShapeRenderBox extends RenderShiftedBox {
  final Color color;
  static const double minWidth = 100;
  static const double padding = 8;
  static const double connectorWidth = 30;
  static const double connectorHeight = 10;
  static const double connectorSideWidth = 10;
  static const double connectorXOffset = 15;
  static const double minHeight = padding * 2 + connectorHeight * 2;
  static const double cornerSize = 5;

  CommandShapeRenderBox({required this.color}) : super(null);
  @override
  void paint(PaintingContext context, Offset offset) {
    // context.canvas.drawRRect(
    //   RRect.fromRectXY(offset & size, 5, 5),
    //   Paint()..color=color,
    // );
    Path path = Path();
    path.moveTo(offset.dx + cornerSize, offset.dy);
    path.lineTo(offset.dx + connectorXOffset, offset.dy);
    path.lineTo(
      offset.dx + connectorXOffset + connectorSideWidth,
      offset.dy + connectorHeight,
    );
    path.lineTo(
      offset.dx + connectorXOffset + connectorWidth - connectorSideWidth,
      offset.dy + connectorHeight,
    );
    path.lineTo(offset.dx + connectorXOffset + connectorWidth, offset.dy);
    path.lineTo(offset.dx + size.width - cornerSize, offset.dy);
    path.quadraticBezierTo(
      offset.dx + size.width,
      offset.dy,
      offset.dx + size.width,
      offset.dy + cornerSize,
    );
    path.lineTo(
      offset.dx + size.width,
      offset.dy + size.height - connectorHeight - cornerSize,
    );
    path.quadraticBezierTo(
      offset.dx + size.width,
      offset.dy + size.height - connectorHeight,
      offset.dx + size.width - cornerSize,
      offset.dy + size.height - connectorHeight,
    );
    path.lineTo(
      offset.dx + connectorXOffset + connectorWidth,
      offset.dy + size.height - connectorHeight,
    );
    path.lineTo(
      offset.dx + connectorXOffset + connectorWidth - connectorSideWidth,
      offset.dy + size.height,
    );
    path.lineTo(
      offset.dx + connectorXOffset + connectorSideWidth,
      offset.dy + size.height,
    );
    path.lineTo(
      offset.dx + connectorXOffset,
      offset.dy + size.height - connectorHeight,
    );
    path.lineTo(
      offset.dx + cornerSize,
      offset.dy + size.height - connectorHeight,
    );
    path.quadraticBezierTo(
      offset.dx,
      offset.dy + size.height - connectorHeight,
      offset.dx,
      offset.dy + size.height - connectorHeight - cornerSize,
    );
    path.lineTo(offset.dx, offset.dy + cornerSize);
    path.quadraticBezierTo(
      offset.dx,
      offset.dy,
      offset.dx + cornerSize,
      offset.dy,
    );
    context.canvas.drawPath(path, Paint()..color = color);
    super.paint(context, offset);
  }

  @override
  void performLayout() {
    (child?.parentData as BoxParentData).offset = Offset(
      padding,
      padding + connectorHeight,
    );
    child?.layout(
      constraints.copyWith(
        maxHeight: constraints.maxHeight - (padding * 2 + connectorHeight * 2),
        maxWidth: constraints.maxWidth - padding * 2,
      ),
      parentUsesSize: true,
    );
    if (child == null) {
      size = Size(minWidth, minHeight);
    } else {
      size = Size(
        max(child!.size.width + padding * 2, minWidth),
        child!.size.height + padding * 2 + connectorHeight * 2,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    if (position.dy < size.height - connectorHeight &&
        position.dy > connectorHeight) {
      return true;
    }
    if (position.dx < connectorXOffset &&
        position.dy < size.height - connectorHeight) {
      return true;
    }
    if (position.dx > connectorXOffset + connectorWidth &&
        position.dy < size.height - connectorHeight) {
      return true;
    }
    if (position.dx > connectorXOffset + connectorSideWidth &&
        position.dx < connectorXOffset + connectorWidth - connectorSideWidth &&
        position.dy > connectorHeight) {
      return true;
    }
    return false;
  }
}
