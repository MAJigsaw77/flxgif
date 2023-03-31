# flxgif

[Yagp's Gif Player](https://github.com/yanrishatum/yagp/) for HaxeFlixel.

### Installation

You can install it through `Haxelib`
```bash
haxelib install flxgif
```
Or through `Git`, if you want the latest updates
```bash
haxelib git flxgif https://github.com/MAJigsaw77/flxgif.git
```

### Basic Usage Example

```haxe
import flxgif.FlxGifSprite;

var nikki:FlxGifSprite = new FlxGifSprite(0, 0);
nikki.loadGif('assets/nikki.gif');
nikki.screenCenter();
nikki.antialiasing = true;
add(nikki);
```
