import 'dart:io';

import 'package:snaplang/structure.dart';

void main() {
  Project project = Project(name: 'Test-Cat');
  Script script = Script(x: 100, y: 100);
  project.scenes.single.sprites.single.scripts.add(script);
  Block block = Block('reportBoolean');
  block.children.add(Block('reportBoolean'));
  script.blocks.add(block);
  File('../snap-files/testcat.xml').writeAsStringSync(
    project.serialize().toXmlString(pretty: true),
  );
}
