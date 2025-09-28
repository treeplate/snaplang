import 'package:xml/xml.dart';

class Project {
  String name;
  late List<Scene> scenes = [Scene(name: name)];
  int currentScene = 0;

  Project({required this.name});
  XmlDocument serialize() {
    return XmlDocument([
      XmlElement(
        XmlName('project'),
        [
          XmlAttribute(XmlName('name'), name),
          XmlAttribute(
            XmlName('app'),
            'TreeSnap 0.0.3, https://treeplate.damowmow.com/snap',
          ),
          XmlAttribute(XmlName('version'), '2'),
        ],
        [
          // <notes>
          // <thumbnail>
          XmlElement(
            XmlName('scenes'),
            [XmlAttribute(XmlName('select'), (currentScene+1).toString())],
            [...scenes.map((e) => e.serialize())],
          ),
        ],
      ),
    ]);
  }
}

class Scene {
  String name;
  List<Sprite> sprites = [Sprite(name: 'Sprite')];
  int currentSprite = 0;

  Scene({required this.name});
  XmlElement serialize() {
    return XmlElement(
      XmlName('scene'),
      [XmlAttribute(XmlName('name'), name)],
      [
        // <notes>
        // <hidden>
        // <headers>
        // <code>
        // <blocks>
        // <primitives>
        XmlElement(
          XmlName('stage'),
          [
            XmlAttribute(XmlName('name'), 'Stage'),
            // width
            // height
            // costume
            // color
            // tempo
            // threadsafe
            // penlog
            // volume
            // pan
            // lines
            // ternary
            // hyperops
            // codify
            XmlAttribute(XmlName('inheritance'), 'true'),
            // inheritance
            // sublistIDs
            // id
          ],
          [
            // <pentrails>
            // <costumes>
            // <sounds>
            XmlElement(XmlName('variables'), [], []),
            XmlElement(XmlName('blocks'), [], []),
            XmlElement(XmlName('scripts'), [], []),
            XmlElement(
              XmlName('sprites'),
              [XmlAttribute(XmlName('select'), (currentSprite+1).toString())],
              [...sprites.map((e) => e.serialize())],
            ),
          ],
        ),
      ],
    );
  }
}

class Sprite {
  String name;
  final List<Script> scripts = [];
  Sprite({required this.name});
  XmlElement serialize() {
    return XmlElement(
      XmlName('sprite'),
      [
        XmlAttribute(XmlName('name'), 'Sprite'),
        // idx
        // x
        // y
        // heading
        // scale
        // volume
        // pan
        // rotation
        XmlAttribute(XmlName('draggable'), 'true'),
        // costume
        // color
        // pen
        // id
      ],
      [
        // <costumes>
        // <sounds>
        XmlElement(XmlName('blocks'), [], []),
        XmlElement(XmlName('variables'), [], []),
        XmlElement(XmlName('scripts'), [], [
          ...scripts.map((e) => e.serialize()),
        ]),
      ],
    );
  }
}

class Script {
  double x;
  double y;
  final List<Block> blocks = [];

  Script({required this.x, required this.y});
  XmlElement serialize() {
    return XmlElement(
      XmlName('script'),
      [
        XmlAttribute(XmlName('x'), x.toString()),
        XmlAttribute(XmlName('y'), y.toString()),
      ],
      [...blocks.map((e) => e.serialize())],
    );
  }
}

abstract class Expression {
  XmlElement serialize();
}

class Block extends Expression {
  String name;
  List<Expression> children = [];

  Block(this.name);
  @override
  XmlElement serialize() {
    return XmlElement(
      XmlName('block'),
      [XmlAttribute(XmlName('s'), name)],
      [
        if (children.isNotEmpty)
          children.length > 1
              ? XmlElement(XmlName('list'), [], [
                  ...children.map((e) => e.serialize()),
                ])
              : children.single.serialize(),
      ],
    );
  }
}

class LExpression extends Expression {
  String data = '';
  @override
  XmlElement serialize() {
    return XmlElement(XmlName('l'), [], [XmlText(data)]);
  }
}
