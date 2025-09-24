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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
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
                DraggedBlock(
                  script: null,
                  draggedBlock: TextEditingController(),
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
                    Script(x: details.offset.dx, y: details.offset.dy-60)
                      ..blocks.add(Block(details.data.$2.text)),
                  );
                });
              },
              builder: (context, _, _) => SizedBox.expand(
                child: ColoredBox(
                  color: Colors.green,
                  child: Stack(
                    children: [
                      ...sprite.scripts.map(
                        (e) => Positioned(
                          top: e.y,
                          left: e.x,
                          child: DraggedBlock(
                            script: e,
                            draggedBlock: TextEditingController(
                              text: e.blocks.single.name,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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

class DraggedBlock extends StatelessWidget {
  const DraggedBlock({
    super.key,
    required this.draggedBlock,
    required this.script,
  });

  final Script? script;
  final TextEditingController draggedBlock;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: (script, draggedBlock),
      feedback: Material(
        child: Container(
          width: 100,
          height: 60,
          color: Colors.orange,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: draggedBlock,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (e) {
                script?.blocks.single.name = e;
              },
            ),
          ),
        ),
      ),
      childWhenDragging: Container(width: 100, height: 60, color: Colors.grey),
      child: Material(
        child: Container(
          width: 100,
          height: 60,
          color: Colors.orange,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: draggedBlock,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (e) {
                script?.blocks.single.name = e;
              }
            ),
          ),
        ),
      ),
    );
  }
}
