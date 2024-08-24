# flxgif

![](https://img.shields.io/github/repo-size/MAJigsaw77/flxgif) ![](https://badgen.net/github/open-issues/MAJigsaw77/flxgif) ![](https://badgen.net/badge/license/MIT/green)

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

var gif:FlxGifSprite = new FlxGifSprite(0, 0);
gif.loadGif('assets/file.gif');
gif.screenCenter();
gif.antialiasing = true;
add(gif);
```

> [!TIP]
> Don't use `gif` files that are really big or that have alot of frames, `Yagp` will not work so well and will cause lag.

### Licensing

**flxgif** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.
