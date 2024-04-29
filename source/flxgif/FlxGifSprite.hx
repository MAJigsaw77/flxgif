package flxgif;

import com.yagp.GifDecoder;
import com.yagp.GifPlayer;
import com.yagp.GifRenderer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flxgif.FlxGifAsset;
import haxe.io.Bytes;
import openfl.utils.Assets;
import openfl.utils.ByteArray;

/**
 * `FlxGifSprite` is made for displaying gif files using `Yagp`.
 * 
 * @author Mihai Alexandru (M.A. Jigsaw).
 */
class FlxGifSprite extends FlxSprite
{
	/**
	 * The Gif Player (warning: can be `null`).
	 */
	public var player(default, null):GifPlayer;

	/**
	 * The Gif SpriteMap (warning: can be `null`).
	 */
	public var map(default, null):GifMap;

	/**
	 * Creates a `FlxGifSprite` at a specified position with a specified gif.
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 *
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 * @param simpleGif The gif you want to display
	 */
	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGif:FlxGifAsset):Void
	{
		super(x, y);

		if (simpleGif != null)
			loadGif(simpleGif);
	}

	/**
	 * Load an gif from an embedded gif file.
	 *
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you load an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the `pixels` field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   gif        The gif you want to use.
	 * @param   asMap      Whether the gif should be loaded as a spritemap to be animated or not.
	 * @param   unique     Whether the gif should be a unique instance in the graphics cache.
	 *                     Set this to `true` if you want to modify the `pixels` field without changing
	 *                     the `pixels` of other sprites with the same `BitmapData`.
	 * @param   key        Set this parameter if you're loading `BitmapData`.
	 * @return  This `FlxGifSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGif(gif:FlxGifAsset, asMap:Bool = false, unique:Bool = false, ?key:String):FlxGifSprite
	{
		if (player != null)
		{
			player.dispose(true);
			player = null;
		}

		if (map != null)
		{
			map.data = FlxDestroyUtil.dispose(map.data);
			map = null;
		}

		if (!asMap)
		{
			if ((gif is ByteArrayData))
				player = new GifPlayer(GifDecoder.parseByteArray(gif));
			else if ((gif is Bytes))
				player = new GifPlayer(GifDecoder.parseByteArray(ByteArray.fromBytes(gif)));
			else // String case
				player = new GifPlayer(GifDecoder.parseByteArray(Assets.getBytes(Std.string(gif))));

			loadGraphic(player.data, false, 0, 0, unique, key);
		}
		else
		{
			if ((gif is ByteArrayData))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(gif));
			else if ((gif is Bytes))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(ByteArray.fromBytes(gif)));
			else // String case
				map = GifRenderer.createMap(GifDecoder.parseByteArray(Assets.getBytes(Std.string(gif))));

			loadGraphic(map.data, true, map.width, map.height, unique, key);
		}

		return this;
	}

	public override function update(elapsed:Float):Void
	{
		if (player != null)
			player.update(elapsed);

		super.update(elapsed);
	}

	public override function destroy():Void
	{
		if (player != null)
		{
			player.dispose(true);
			player = null;
		}

		if (map != null)
		{
			map.data = FlxDestroyUtil.dispose(map.data);
			map = null;
		}
			
		super.destroy();
	}
}
