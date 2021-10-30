library blocks;

import 'package:stagexl/stagexl.dart';
import 'dart:html' hide MouseEvent;
import 'dart:html' as html;
import 'dart:async';
import 'dart:math';

part 'resources.dart';
part 'puzzle.dart';
part 'hero.dart';
part 'states.dart';
part 'view.dart';
part 'editorgui.dart';

final TILE_SIZE = 16;

final hero = new Hero();
final Set keyPresses = new Set();
Puzzle currentPuzzle;
bool ctrlKey = false;

void main() {
  //TODO: ctrlKey workaround...
  html.querySelector('#stage').onKeyDown.listen((event) => ctrlKey = event.ctrlKey);
  html.querySelector('#stage').onKeyUp.listen((event) => ctrlKey = event.ctrlKey);
  
  Resources.load(start); //loads resources, then calls start()
}

void start() {  
  StageXL.stageOptions.transparent = true;
  StageXL.stageOptions.backgroundColor = Color.Transparent;

  final view = new ViewObject();
  final EditorState editorState = new EditorState(view);
  final InputCustomPuzzleState inputCustomPuzzleState = new InputCustomPuzzleState(view);
  
  final stage = new Stage(html.querySelector("#stage"));
  final editorSelectionStage = new Stage(html.querySelector("#editor-selection-stage"));
  final editorGui = new EditorGui(editorSelectionStage, editorState);
  
  void loadDefaultPuzzle() {
    view.state = new PlayingGameState(view, new Puzzle(TITLESCREEN_PUZZLE));
  }
  
  html.querySelector('#input-custom-puzzle-button').onClick.listen((_) => inputCustomPuzzleState.loadPuzzleFromInput());
  html.querySelector('#play-custom-puzzle-button').onClick.listen((_) => view.state = inputCustomPuzzleState);
  html.querySelector('#open-editor-button').onClick.listen((_) => view.state = editorState);
  html.querySelector('#main-menu-button').onClick.listen((_) => loadDefaultPuzzle());
  html.querySelector('#reload-button').onClick.listen((_) => view.state = new PlayingGameState(view, new Puzzle(currentPuzzle.data)));
  
  stage.focus = stage;
  stage.addChild(view);
  stage.onKeyUp.listen((e) => keyPresses.remove(e.keyCode));
  stage.onKeyDown.listen((e) => keyPresses.add(e.keyCode));
  stage.onEnterFrame.listen((_) => view.update());
  loadDefaultPuzzle();
  new RenderLoop()..addStage(stage)..addStage(editorSelectionStage);
}