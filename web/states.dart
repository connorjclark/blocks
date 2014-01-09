part of blocks;

class StateMachine {
  final GameObject obj;
  State _state;
  
  StateMachine(this.obj) : _state = NullState.INSTANCE;
  
  void set state(State state) {
    _state.exit();
    _state = state;
    _state.enter();
  }
  
  void update() => _state.update();
}

class State {
  static final NULL_STATE = State;
  
  final StateMachine stateMachine;
  final GameObject obj;
  
  void enter() {}
  void update() {}
  void exit() {}
  
  //TODO I wish I could just use this.obj here...
  State(GameObject obj) : stateMachine = obj.stateMachine, this.obj = obj;
  
  State._null() : stateMachine = null, obj = null;
}

class GameObject extends Sprite {
  //TODO make private?
  StateMachine stateMachine;
  
  void set state(state) {
    stateMachine.state = state;
  }
  
  void update() => stateMachine.update();
  
  GameObject({State initialState: null}) {
    stateMachine = new StateMachine(this);
    if (initialState != null) state = initialState;
  }
}

class NullState extends State {
  static final INSTANCE = new NullState();
  
  NullState() : super._null();
}

class MovingState extends State {
  static final ICE_SPEED = 2;
  
  final int speed, dx, dy;
  
  MovingState(GameObject obj, this.speed, this.dx, this.dy) : super(obj);
  
  void update() {
    obj.x += speed * dx;
    obj.y += speed * dy;
    if (obj.x % TILE_SIZE == 0 && obj.y % TILE_SIZE == 0) {
      if (obj is Hero) {
        stateMachine.state = new HeroWaitingState(obj);
      } else {
        //ice logic
        State newState = NullState.INSTANCE;
        if (currentPuzzle.hasIce(obj.x ~/ TILE_SIZE, obj.y ~/ TILE_SIZE)) {
          currentPuzzle.removeBlock(obj.x ~/ TILE_SIZE - dx, obj.y ~/ TILE_SIZE - dy);
          currentPuzzle.setBlock(obj.x ~/ TILE_SIZE, obj.y ~/ TILE_SIZE, newBlock: obj as Block);
          if (currentPuzzle.hasIce(obj.x ~/ TILE_SIZE + dx, obj.y ~/ TILE_SIZE + dy) 
              && currentPuzzle.getBlock(obj.x ~/ TILE_SIZE + dx, obj.y ~/ TILE_SIZE + dy) == null
              && !currentPuzzle.hasButtonTrigger(obj.x ~/ TILE_SIZE, obj.y ~/ TILE_SIZE)
          ) {
            newState = new MovingState(obj, ICE_SPEED, dx, dy);
          } else {
            currentPuzzle.checkForWin();
          }
          
        } else if (currentPuzzle.hasTrigger(obj.x ~/ TILE_SIZE, obj.y ~/ TILE_SIZE)) currentPuzzle.checkForWin();
                
        stateMachine.state = newState;
      }
    }
  }
}

class HeroWaitingState extends State {
  int pushingOnBlockTicker = 0;
  
  HeroWaitingState(Hero hero) : super(hero);
    
  void update() {
    int dx, dy;
    dx = dy = 0;
    if (keyPresses.contains(KeyCode.LEFT) || keyPresses.contains(KeyCode.A)) dx = -1;
    if (keyPresses.contains(KeyCode.RIGHT) || keyPresses.contains(KeyCode.D)) dx = 1;
    if (dx == 0) {
      if (keyPresses.contains(KeyCode.UP) || keyPresses.contains(KeyCode.W)) dy = -1;
      if (keyPresses.contains(KeyCode.DOWN) || keyPresses.contains(KeyCode.S)) dy = 1;
    }
    if (dx != 0 || dy != 0) {
      final blockx = hero.x ~/ TILE_SIZE + dx;
      final blocky = hero.y ~/ TILE_SIZE + dy;
      if (!currentPuzzle.inBounds(blockx, blocky)) return;
      if (!currentPuzzle.hasBlock(blockx, blocky)) {
        stateMachine.state = new MovingState(hero, 2, dx, dy);
      } else if(pushingOnBlockTicker > 10 && currentPuzzle.canMoveBlockInDir(blockx, blocky, dx, dy) && currentPuzzle.getBlock(blockx + dx, blocky + dy) == null) {
        final block = currentPuzzle.getBlock(blockx, blocky);
        block.hasMoved = true;
        currentPuzzle.removeBlock(hero.x ~/ TILE_SIZE + dx, hero.y ~/ TILE_SIZE + dy);
        currentPuzzle.setBlock(hero.x ~/ TILE_SIZE + dx*2, hero.y ~/ TILE_SIZE + dy*2, newBlock: block);
        final onIce = currentPuzzle.hasIce(blockx, blocky) && currentPuzzle.hasIce(blockx + dx, blocky + dy);
        block.stateMachine.state = new MovingState(block, onIce ? MovingState.ICE_SPEED : 1, dx, dy);
        stateMachine.state = new MovingState(hero, 1, dx, dy);
      } else pushingOnBlockTicker += 1;
    } else pushingOnBlockTicker = 0;
  }
}