part of blocks;

class Resources {
  static final resourceManager = new ResourceManager();
  static List<BitmapData> floor_bmds, trigger_bmds, block_bmds;
    
  static void load(then) {
    resourceManager..addBitmapData('block-ss', 'images/block-ss.png')
      ..addBitmapData('floor-ss', 'images/floor-ss.png')
      ..addBitmapData('trigger-ss', 'images/trigger-ss.png')
      ..addBitmapData('hero', 'images/hero.png')
      ..load().then((_) {
        final zero = new Point(0, 0);
        List<BitmapData> extractSprites(BitmapData ss) {
          return new List.generate(ss.width ~/ TILE_SIZE, (i) {
            final bmd = new BitmapData(16, 16);
            bmd.copyPixels(ss, new Rectangle(i * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE), zero);
            return bmd;
          });
        }
        
        floor_bmds = extractSprites(resourceManager.getBitmapData('floor-ss'));
        trigger_bmds = extractSprites(resourceManager.getBitmapData('trigger-ss'));
        block_bmds = extractSprites(resourceManager.getBitmapData('block-ss'));
        
        then();
      }); 
  }
}