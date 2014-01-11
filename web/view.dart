part of blocks;

class ViewObject extends GameObject {  
  void hide(List<String> divs) => divs.forEach((div) => querySelector(div).className = 'hidden');
  void show(List<String> divs) => divs.forEach((div) => querySelector(div).className = '');
  void scaleTo(Sprite sprite) {
    this.scaleX = stage.stageWidth / sprite.width;
    this.scaleY = stage.stageHeight / sprite.height;
  }
}

class ViewState extends State {
  final ViewObject view;
  
  ViewState(ViewObject view) : this.view = view, super(view);
    
  void exit() {
    if (view.numChildren > 0) view.removeChildren();
  }
}

class PlayingGameState extends ViewState {
  final Puzzle puzzle;
  StreamSubscription onWinSubscription;
  
  PlayingGameState(ViewObject view, this.puzzle) : super(view);
  
  void enter() {
    currentPuzzle = puzzle;
    view.addChild(puzzle);
    view.addChild(hero);
    view.show(['#stage-div', '#menu-div']);
    view.hide(['#main-menu-button-div']);
    onWinSubscription = currentPuzzle.onWin.listen((_) => querySelector('#win-div').className = 'visible');
    view.scaleTo(puzzle);
  }
  
  void update() {
    hero.update();
    currentPuzzle.tiles.expand((i) => i).toList().map((tile) => tile.block).forEach((block) {
      if (block != null) block.update();
    });
  }
  
  void exit() {
    super.exit();
    view.hide(['#stage-div', '#menu-div', '#win-div']);
    view.show(['#main-menu-button-div']);
    
    onWinSubscription.cancel();
  }
}

class EditorState extends ViewState {
  final Bitmap preview;
  int currentSelectionIndex;
  Symbol currentSelectionType = #none;
  
  EditorState(ViewObject view) : preview = new Bitmap(), super(view);
  
  void enter() {
    view.addChild(currentPuzzle = new Puzzle(currentPuzzle.data));
    view.addChild(hero);
    view.addChild(preview);
    view.show(['#stage-div', '#editor-selection-div']);
    
    view.addEventListener(MouseEvent.CLICK, onMouseClick);
    view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    view.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    updatePuzzleExportTextArea();
    view.scaleTo(currentPuzzle);
  }
  
  void update() {
    hero.update();
    currentPuzzle.tiles.expand((i) => i).toList().map((tile) => tile.block).forEach((block) {
      if (block != null) block.update();
    });
  }
  
  void exit() {
    super.exit();
    view.hide(['#editor-selection-div']);
    
    view.removeEventListener(MouseEvent.CLICK, onMouseClick);
    view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    view.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }
  
  void updatePuzzleExportTextArea() {
    querySelector('#puzzle-export').text = currentPuzzle.encode();
  }
  
  void setPreviewImage(Symbol type, int index) {
    currentPuzzle.blockContainer.alpha = 0.5;
    if (type == #floor) {
      preview.bitmapData = Resources.floor_bmds[index];
    } else if (type == #trigger) {
      preview.bitmapData = Resources.trigger_bmds[index];
    } else if (type == #block) {
      preview.bitmapData = Resources.block_bmds[index];
      currentPuzzle.blockContainer.alpha = 1;
    } else if (type == #none) {
      preview.bitmapData = null;
      currentPuzzle.blockContainer.alpha = 1;
    }
  }
  
  void placeSelection(int x, int y, Symbol type, int index) {
    if (currentSelectionType == #floor) {
      currentPuzzle.setFloor(x, y, index);
    } else if (currentSelectionType == #trigger) {
      currentPuzzle.setTrigger(x, y, !ctrlKey ? index + 1 : 0);
    } else if (currentSelectionType == #block) {
      if (ctrlKey) {
        currentPuzzle.setBlock(x, y, value: 0);
      } else {
        final currentBlock = currentPuzzle.getBlock(x, y);
        if (currentBlock == null || currentBlock.intValue != index + 1)
          currentPuzzle.setBlock(x, y, value: index + 1);
      }
    }
    updatePuzzleExportTextArea();
  }
  
  void onMouseClick(MouseEvent event) {
    final x = (event.stageX / view.scaleX) ~/ TILE_SIZE;
    final y = (event.stageY / view.scaleY) ~/ TILE_SIZE;
    placeSelection(x, y, currentSelectionType, currentSelectionIndex);
  }
  
  void onMouseMove(MouseEvent event) {
    final x = (event.stageX / view.scaleX) ~/ TILE_SIZE;
    final y = (event.stageY / view.scaleY) ~/ TILE_SIZE;
    setPreviewImage(currentSelectionType, currentSelectionIndex);
    preview.x = x * TILE_SIZE;
    preview.y = y * TILE_SIZE;
    if (event.buttonDown) {
      placeSelection(x, y, currentSelectionType, currentSelectionIndex);
    }
  }
  
  void onMouseOut(MouseEvent event) {
    setPreviewImage(#none, 0);
  }  
}

class InputCustomPuzzleState extends ViewState {
  InputCustomPuzzleState(ViewObject view) : super(view);
  
  void enter() {
    view.show(['#input-custom-puzzle-div', '#main-menu-button-div']);
  }
  
  void update() {}
  
  void exit() {
    super.exit();
    view.hide(['#input-custom-puzzle-div', '#main-menu-button-div', '#invalid-code-div']);
  }
  
  void loadPuzzleFromInput() {
    try {
      final textarea = querySelector('#puzzle-import') as TextAreaElement;
      view.state = new PlayingGameState(view, new Puzzle(textarea.value));
    } catch (exception, stacktrace) {
      querySelector('#invalid-code-p').text = exception.toString();
      view.show(['#invalid-code-div']);
    }
  }
}