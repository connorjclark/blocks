part of blocks;

class Hero extends GameObject {
  Hero() : super() {
    state = new HeroWaitingState(this);
    final bm = new Bitmap(Resources.resourceManager.getBitmapData('hero'));
    bm.x -= (bm.width - TILE_SIZE) / 2;
    bm.y -= bm.height - TILE_SIZE;
    addChild(bm);
  }
}