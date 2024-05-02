package flxgif;

import com.yagp.GifDecoder;
import com.yagp.GifPlayer;
import com.yagp.GifRenderer;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import flxgif.FlxGifAsset;
import haxe.io.Bytes;
import openfl.utils.Assets;
import openfl.utils.ByteArray;

/**
 * `FlxGifSprite` is made for displaying gif files in HaxeFlixel as sprites.
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
	 *
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 *
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 * @param simpleGif The gif you want to display.
	 */
	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGif:FlxGifAsset):Void
	{
		super(x, y);

		if (simpleGif != null)
			loadGif(simpleGif);
	}

	/**
	 * Call this function to load a gif.
	 *
	 * @param gif The gif you want to use.
	 * @param asMap Whether the gif should be loaded as a spritemap to be animated or not.
	 *
	 * @return This `FlxGifSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGif(gif:FlxGifAsset, asMap:Bool = false):FlxGifSprite
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
			else
				player = new GifPlayer(GifDecoder.parseByteArray(Assets.getBytes(Std.string(gif))));

			loadGraphic(FlxGraphic.fromBitmapData(player.data, false, null, false));
		}
		else
		{
			if ((gif is ByteArrayData))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(gif));
			else if ((gif is Bytes))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(ByteArray.fromBytes(gif)));
			else
				map = GifRenderer.createMap(GifDecoder.parseByteArray(Assets.getBytes(Std.string(gif))));

			loadGraphic(FlxGraphic.fromBitmapData(map.data, false, null, false), true, map.width, map.height);
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
		super.destroy();

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
	}
}
