package flxgif;

#if !flixel_addons
#error 'Your project must use flixel-addons in order to use this class.'
#end
import com.yagp.GifDecoder;
import com.yagp.GifPlayer;
import com.yagp.GifRenderer;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxAxes;
import flixel.util.FlxDestroyUtil;
import flxgif.FlxGifAsset;
import haxe.io.Bytes;
import openfl.utils.Assets;
import openfl.utils.ByteArray;

/**
 * `FlxGifBackdrop` is made for showing infinitely scrolling gif backgrounds using FlxBackdrop.
 */
class FlxGifBackdrop extends FlxBackdrop
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
	 * Creates an instance of the `FlxGifBackdrop` class, used to create infinitely scrolling gif backgrounds.
	 *
	 * @param gif The gif you want to use for the backdrop.
	 * @param repeatAxes The axes on which to repeat. The default, `XY` will tile the entire camera.
	 * @param spacingX Amount of spacing between tiles on the X axis.
	 * @param spacingY Amount of spacing between tiles on the Y axis.
	 */
	#if (flixel_addons >= version("3.2.1"))
	public function new(?gif:FlxGifAsset, repeatAxes = XY, spacingX = 0.0, spacingY = 0.0):Void
	{
		super(repeatAxes, spacingX, spacingY);

		if (gif != null)
			loadGif(gif);
	}
	#else
	public function new(?gif:FlxGifAsset, repeatAxes = XY, spacingX = 0, spacingY = 0):Void
	{
		super(repeatAxes, spacingX, spacingY);

		if (gif != null)
			loadGif(gif);
	}
	#end

	/**
	 * Call this function to load a gif.
	 *
	 * @param gif The gif you want to use.
	 * @param asMap Whether the gif should be loaded as a spritemap to be animated or not.
	 *
	 * @return This `FlxGifBackdrop` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGif(gif:FlxGifAsset, asMap:Bool = false):FlxGifBackdrop
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
