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
@:access(haxe.io.Bytes)
@:access(openfl.utils.ByteArrayData)
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
	 * @param   X               The initial X position of the sprite.
	 * @param   Y               The initial Y position of the sprite.
	 * @param   SimpleGif       The gif you want to display
	 */
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGif:FlxGifAsset):Void
	{
		super(X, Y);
		if (SimpleGif != null)
			loadGif(SimpleGif);
	}

	/**
	 * Load an gif from an embedded gif file.
	 *
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you load an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the `pixels` field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   Gif        The gif you want to use.
	 * @param   AsMap      Whether the gif should be loaded as a spritemap to be animated or not.
	 * @param   Unique     Whether the gif should be a unique instance in the graphics cache.
	 *                     Set this to `true` if you want to modify the `pixels` field without changing
	 *                     the `pixels` of other sprites with the same `BitmapData`.
	 * @param   Key        Set this parameter if you're loading `BitmapData`.
	 * @return  This `FlxGifSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGif(Gif:FlxGifAsset, AsMap:Bool = false, Unique:Bool = false, ?Key:String):FlxGifSprite
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

		if (!AsMap)
		{
			if ((Gif is ByteArrayData))
				player = new GifPlayer(GifDecoder.parseByteArray(Gif));
			else if ((Gif is Bytes))
				player = new GifPlayer(GifDecoder.parseByteArray(ByteArray.fromBytes(Gif)));
			else // String case
				player = new GifPlayer(GifDecoder.parseByteArray(Assets.getBytes(Std.string(Gif))));

			loadGraphic(player.data, false, 0, 0, Unique, Key);
		}
		else
		{
			if ((Gif is ByteArrayData))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(Gif));
			else if ((Gif is Bytes))
				map = GifRenderer.createMap(GifDecoder.parseByteArray(ByteArray.fromBytes(Gif)));
			else // String case
				map = GifRenderer.createMap(GifDecoder.parseByteArray(Assets.getBytes(Std.string(Gif))));

			loadGraphic(map.data, true, map.width, map.height, Unique, Key);
		}

		return this;
	}

	override function update(elapsed:Float):Void
	{
		if (player != null)
			player.update(elapsed);

		super.update(elapsed);
	}

	override function destroy():Void
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
