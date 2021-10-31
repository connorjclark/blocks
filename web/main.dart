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
part 'puzzle-data.dart';

final TILE_SIZE = 16;

final hero = new Hero();
final Set keyPresses = new Set();
Puzzle currentPuzzle;
bool ctrlKey = false;

final view = new ViewObject();
final EditorState editorState = new EditorState(view);
final InputCustomPuzzleState inputCustomPuzzleState = new InputCustomPuzzleState(view);

void main() {
  //TODO: ctrlKey workaround...
  html.querySelector('#stage').onKeyDown.listen((event) => ctrlKey = event.ctrlKey);
  html.querySelector('#stage').onKeyUp.listen((event) => ctrlKey = event.ctrlKey);
  
  Resources.load(start); //loads resources, then calls start()
}

void start() {  
  StageXL.stageOptions.transparent = true;
  StageXL.stageOptions.backgroundColor = Color.Transparent;
  
  final stage = new Stage(html.querySelector("#stage"));
  final editorSelectionStage = new Stage(html.querySelector("#editor-selection-stage"));
  installEditorGuiControls(editorSelectionStage, editorState);
  
  void loadDefaultPuzzle() {
    view.state = new PlayingGameState(view, new Puzzle(TITLESCREEN_PUZZLE));
  }
  
  html.querySelector('#input-custom-puzzle-button').onClick.listen((_) => inputCustomPuzzleState.loadPuzzleFromInput());
  html.querySelector('#play-custom-puzzle-button').onClick.listen((_) => view.state = inputCustomPuzzleState);
  html.querySelector('#main-menu-button').onClick.listen((_) => loadDefaultPuzzle());
  html.querySelector('#reload-button').onClick.listen((_) => view.state = new PlayingGameState(view, new Puzzle(currentPuzzle.originalPuzzleData)));
  
  stage.focus = stage;
  stage.addChild(view);
  stage.onKeyUp.listen((e) => keyPresses.remove(e.keyCode));
  stage.onKeyDown.listen((e) => keyPresses.add(e.keyCode));
  stage.onEnterFrame.listen((_) => view.update());
  loadDefaultPuzzle();
  new RenderLoop()..addStage(stage)..addStage(editorSelectionStage);
}

void installEditorGuiControls(Stage editorSelectionStage, EditorState editorState) {
  final blockSelection = new Sprite()..addChild(new Bitmap(Resources.resourceManager.getBitmapData('block-ss')));
  blockSelection.scaleX = blockSelection.scaleY = 2;
  blockSelection.onMouseClick.listen((e) {
    editorState.currentSelectionIndex = e.localX ~/ TILE_SIZE;
    editorState.currentSelectionType = #block;
  });
  editorSelectionStage.addChild(blockSelection);
  
  final floorSelection = new Sprite()..addChild(new Bitmap(Resources.resourceManager.getBitmapData('floor-ss')));
  floorSelection.scaleX = floorSelection.scaleY = 2;
  floorSelection.x = editorSelectionStage.stageWidth / 2 - floorSelection.width / 2;
  floorSelection.y = TILE_SIZE * 2;
  floorSelection.onMouseClick.listen((e) {
    editorState.currentSelectionIndex = e.localX ~/ TILE_SIZE;
    editorState.currentSelectionType = #floor;
  });
  editorSelectionStage.addChild(floorSelection);
  
  final triggerSelection = new Sprite()..addChild(new Bitmap(Resources.resourceManager.getBitmapData('trigger-ss')));
  triggerSelection.scaleX = triggerSelection.scaleY = 2;
  triggerSelection.x = editorSelectionStage.stageWidth / 2 - triggerSelection.width / 2;
  triggerSelection.y = TILE_SIZE * 4;
  triggerSelection.onMouseClick.listen((e) {
    editorState.currentSelectionIndex = e.localX ~/ TILE_SIZE;
    editorState.currentSelectionType = #trigger;
  });
  editorSelectionStage.addChild(triggerSelection);
}
