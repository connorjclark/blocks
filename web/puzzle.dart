part of blocks;

//TODO: Multiline strings(""") mess up dart2js conversion...why?
final TITLESCREEN_PUZZLE = "8 3\nƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄ\nƄĄĄĄĄĄĄĄĄĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄĄĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄĄĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄĔĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄĄĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄąĄĄĄĄĄĄĄƄ\nƄĄĄĄĄĄĄĄĄĄĄĄĄĄĄĄƄ\nƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄƄ";

class Puzzle extends Sprite {
  final Sprite blockContainer = new Sprite(),
               triggerContainer = new Sprite(),
               floorContainer = new Sprite();
  final List<List<Tile>> tiles; //tiles[y][x]
  final onWinController = new StreamController.broadcast();
  final String data;
  get onWin => onWinController.stream;
  
  factory Puzzle(String data) {
    final split = data.split("\n");
    final dataArray = split.sublist(1);
    
    final start = split[0].split(" ").map((_) {
      try {
        return int.parse(_);
      } catch(exception, stacktrace) {
        print(stacktrace);
        throw 'Can\'t read starting values. Make sure the first line contains two numbers, separated by a space.';
      }
    }).toList();
    
    if (dataArray.last.isEmpty) dataArray.removeLast();
    
    final tilesHorizontal = dataArray[0].length;
    final tilesVertical = dataArray.length;
    
    dataArray.forEach((row) {
      if (row.length != tilesHorizontal)
        throw 'Inconsistent row sizes for puzzle input. Maybe line ${dataArray.indexOf(row) + 2}?';
    });
    
    return new Puzzle._private(dataArray, tilesHorizontal, tilesVertical, start[0], start[1]);
  }
  
  Puzzle._private(List<String> data, int tilesHorizontal, int tilesVertical, int startX, int startY) :
    tiles = new List.generate(tilesVertical, (y) =>
      new List.generate(tilesHorizontal, (x) =>
        new Tile(x, y, data[y].codeUnitAt(x) - 256)
      )
    ),
    data = '$startX $startY\n' + data.join("\n")
  {
    //catch all mouse events
    final shape = new Shape();
    shape.graphics..rect(0, 0, tilesHorizontal * TILE_SIZE, tilesVertical * TILE_SIZE)..fillColor(Color.Transparent);
    addChild(shape);
    
    addChild(floorContainer);
    addChild(triggerContainer);
    addChild(blockContainer);
    
    hero.x = startX * TILE_SIZE;
    hero.y = startY * TILE_SIZE;
        
    tiles.expand((_) => _).forEach((tile) {
      if (tile.block != null) blockContainer.addChild(tile.block);
      triggerContainer.addChild(tile.trigger);
      floorContainer.addChild(tile.floor);
    });
  }
  
  String encode() => "${getWidth() ~/ 2} ${getHeight() ~/ 2}\n" + tiles.map((list) =>
      list.map((tile) =>
          new String.fromCharCode(tile.encode() + 256)
      ).join()
  ).join('\n');
  
  void checkForWin() {
    final width = getWidth(), height = getHeight();
    for (var x = 0; x < getWidth(); x++) {
      for (var y = 0; y < getHeight(); y++) {
        if (hasTrigger(x, y) && getBlock(x, y) == null) return;
      }
    }
    onWinController.add("win");
  }
  
  int getWidth() => tiles[0].length;
  int getHeight() => tiles.length;
  bool inBounds(int x, int y) => x >= 0 && y >= 0 && y < getHeight() && x < getWidth();
  
  Tile getTile(int x, int y) => tiles[y][x];
  Floor getFloor(int x, int y) => tiles[y][x].floor;
  Trigger getTrigger(int x, int y) => tiles[y][x].trigger;
  Block getBlock(int x, int y) => tiles[y][x].block;
  
  bool hasBlock(int x, int y) => tiles[y][x].block != null;
  bool hasIce(int x, int y) => getFloor(x, y).type == #ice;
  bool hasSand(int x, int y) => getFloor(x, y).type == #sand;
  bool hasTrigger(int x, int y) => getTrigger(x, y).type != #none;
  bool hasButtonTrigger(int x, int y) => getTrigger(x, y).type == #button;
  
  setFloor(int x, int y, int typeIndex) => getFloor(x, y).type = Floor.types[typeIndex];
  setTrigger(int x, int y, int typeIndex) => getTrigger(x, y).type = Trigger.types[typeIndex];
  
  //TODO: refactor
  void setBlock(int x, int y, {int value, Block newBlock}) {
    final block = tiles[y][x].block;
    final _newBlock = newBlock != null ? newBlock : new Block(value);
    if (block != null) blockContainer.removeChild(block);
    if (_newBlock != null) blockContainer.addChild(_newBlock);
    tiles[y][x].block = _newBlock;
    if (newBlock == null && value != 0) {
      _newBlock.x = x * TILE_SIZE;
      _newBlock.y = y * TILE_SIZE;
    }
  }
  void removeBlock(int x, int y) => setBlock(x, y, value: 0);
  
  bool canMoveBlockInDir(int x, int y, int dx, int dy) {
    if (hasButtonTrigger(x, y) || !inBounds(x + dx, y + dy) || hasBlock(x + dx, y + dy) || hasSand(x + dx, y + dy))
      return false;
    return getBlock(x, y).canMove(dx, dy);
  }
}

class Tile {
  Block block;
  Trigger trigger;
  Floor floor;
  
  factory Tile(int x, int y, int value) {
    final blockValue = value >> 4;
    final floorValue = (value >> 2) & 3;
    final triggerValue = value & 3;
    return new Tile._private(x, y, new Block(blockValue), new Trigger(triggerValue), new Floor(floorValue));
  }
  
  Tile._private(int x, int y, this.block, this.trigger, this.floor) {
    if (block != null) { block.x = x * TILE_SIZE; block.y = y * TILE_SIZE; }
    trigger.x = x * TILE_SIZE; trigger.y = y * TILE_SIZE; 
    floor.x = x * TILE_SIZE; floor.y = y * TILE_SIZE;
  }
  
  int encode() {
    final blockValue = block != null ? block.intValue : 0;
    return (blockValue << 4) + (floor.intValue << 2) + trigger.intValue;
  }
}

class Block extends GameObject {
  static final directions = [#all, #h, #v, #u, #d, #l, #r];
  
  final bool once, moveable;
  final Symbol dir;
  bool hasMoved = false;
  
  factory Block(int value) {
    final type = value >> 3;
    final dir = value & 7;
    
    if (dir == 0 && type == 0) return null;
    if (dir == 0 && type == 1) return new Block._private(moveable: false);
    
    return new Block._private(dir: directions[dir - 1], once: type == 1);
  }
  
  get intValue => moveable ? (1 + directions.indexOf(dir) + (once ? 1 << 3 : 0)) : (1 << 3);
  
  Block._private({this.dir: #all, this.once: false, this.moveable: true}) : super() {
    final bmdIndex = !moveable ? 7 : (directions.indexOf(dir) + (once ? 1 + directions.length : 0));
    final bm = new Bitmap(Resources.block_bmds[bmdIndex]);
    addChild(bm);
  }
  
  bool canMove(int dx, int dy) {
    final x = this.x ~/ TILE_SIZE, y = this.y ~/ TILE_SIZE;
    if (!moveable || (once && hasMoved) || (dx != 0 && dy != 0)) return false;
    if (dir == #all || (dir == #h && dy == 0) || (dir == #v && dx == 0)) return true;
    if (dx == 1) return dir == #r;
    if (dx == -1) return dir == #l;
    if (dy == 1) return dir == #d;
    if (dy == -1) return dir == #u;
  }
}

class Trigger extends Sprite {
  static final types = [#none, #button, #marker];
  
  Symbol _type;
  final Bitmap bm;
  
  factory Trigger(int value) {
    return new Trigger._private(types[value]);
  }
  
  Trigger._private(_type) : bm = new Bitmap(_type != #none ? Resources.trigger_bmds[types.indexOf(_type) - 1] : null) {
    this._type = _type;
    addChild(bm);
  }
  
  get type => _type;
  get intValue => types.indexOf(_type);
  
  void set type(Symbol type) {
    bm.bitmapData = type != #none ? Resources.trigger_bmds[types.indexOf(type) - 1] : null;
    _type = type;
  }
}

class Floor extends Sprite {
  static final types = [#sand, #normal, #ice];
  
  Symbol _type;
  final Bitmap bm;
  
  factory Floor(int value) {
    return new Floor._private(types[value]);
  }
  
  Floor._private(type) : bm = new Bitmap() {
    this.type = type;
    addChild(bm);
  }
  
  get type => _type;
  get intValue => types.indexOf(_type);
  
  void set type(Symbol type) {
    if (type == #sand)
      bm.bitmapData = null;
    else
      bm.bitmapData = Resources.floor_bmds[types.indexOf(type)];
    _type = type;
  }
}