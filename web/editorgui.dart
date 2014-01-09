part of blocks;

class EditorGui extends Sprite {
  EditorGui(Stage editorSelectionStage, EditorState editorState) {
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
}