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
  Path? path;

  CommandShapeRenderBox({required this.color}) : super(null);
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawPath(path!.shift(offset), Paint()..color = color);
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
    path = Path();
    path!.moveTo(cornerSize, 0);
    path!.lineTo(connectorXOffset, 0);
    path!.lineTo(
      connectorXOffset + connectorSideWidth,
      connectorHeight,
    );
    path!.lineTo(
      connectorXOffset + connectorWidth - connectorSideWidth,
      connectorHeight,
    );
    path!.lineTo(connectorXOffset + connectorWidth, 0);
    path!.lineTo(size.width - cornerSize, 0);
    path!.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerSize,
    );
    path!.lineTo(
      size.width,
      size.height - connectorHeight - cornerSize,
    );
    path!.quadraticBezierTo(
      size.width,
      size.height - connectorHeight,
      size.width - cornerSize,
      size.height - connectorHeight,
    );
    path!.lineTo(
      connectorXOffset + connectorWidth,
      size.height - connectorHeight,
    );
    path!.lineTo(
      connectorXOffset + connectorWidth - connectorSideWidth,
      size.height,
    );
    path!.lineTo(
      connectorXOffset + connectorSideWidth,
      size.height,
    );
    path!.lineTo(
      connectorXOffset,
      size.height - connectorHeight,
    );
    path!.lineTo(
      cornerSize,
      size.height - connectorHeight,
    );
    path!.quadraticBezierTo(
      0,
      size.height - connectorHeight,
      0,
      size.height - connectorHeight - cornerSize,
    );
    path!.lineTo(0, cornerSize);
    path!.quadraticBezierTo(
      0,
      0,
      cornerSize,
      0,
    );
  }

  @override
  bool hitTestSelf(Offset position) {
    return path!.contains(position);
  }
}
