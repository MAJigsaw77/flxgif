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

var nikki:FlxGifSprite = new FlxGifSprite(0, 0);
nikki.loadGif('assets/nikki.gif');
nikki.screenCenter();
nikki.antialiasing = true;
add(nikki);
```

### Licensing

**flxgif** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.
