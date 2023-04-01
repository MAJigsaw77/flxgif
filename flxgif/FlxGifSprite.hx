package flxgif;

import com.yagp.GifDecoder;
import com.yagp.GifPlayer;
import flixel.FlxSprite;
import flxgif.FlxGifAsset;
import openfl.utils.Assets;
import openfl.utils.ByteArray;
import haxe.io.Bytes;

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
	 * The Timescale for this.
	 */
	public var timeScale:Float = 1;

	/**
	 * If the player must play the animation?
	 */
	public var playing(get, set):Bool;

	/**
	 * Handler of animation end. Note, it will be called only if animation does not have infinite amount of loops.
	 */
	public var animationEndHandler(get, set):Void->Void;

	/**
	 * Handler of animation loop end. Will be called on end of each loop.
	 */
	public var loopEndHandler(get, set):Void->Void;

	/**
	 * Current frame index.
	 */
	public var frame(get, set):Int;

	/**
	 * Amount of frames in assigned Gif file.
	 */
	public var framesCount(get, never):Int;

	/**
	 * The Gif Player.
	 */
	public var player:GifPlayer;

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
	 * @param   Width      Specify the width of your sprite
	 *                     (helps figure out what to do with non-square sprites or sprite sheets).
	 * @param   Height     Specify the height of your sprite
	 *                     (helps figure out what to do with non-square sprites or sprite sheets).
	 * @param   Unique     Whether the gif should be a unique instance in the graphics cache.
	 *                     Set this to `true` if you want to modify the `pixels` field without changing
	 *                     the `pixels` of other sprites with the same `BitmapData`.
	 * @param   Key        Set this parameter if you're loading `BitmapData`.
	 * @return  This `FlxGifSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGif(Gif:FlxGifAsset, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxGifSprite
	{
		if (player != null)
		{
			player.dispose(true);
			player = null;
		}

		if ((Gif is ByteArrayData))
			player = new GifPlayer(GifDecoder.parseByteArray(Gif));
		else if ((Gif is Bytes))
			player = new GifPlayer(GifDecoder.parseByteArray(ByteArray.fromBytes(Gif)));
		else // String case
			player = new GifPlayer(GifDecoder.parseByteArray(Assets.getBytes(Std.string(Gif))));

		loadGraphic(player.data, false, Width, Height, Unique, Key);

		return this;
	}

	/**
	 * Resets player state. Use it foor reset loop counter.
	 *
	 * @param play If set to true, will force `playing` value to true.
	 */
	public function reset(play:Bool = false):Void
	{
		if (player != null)
			player.reset(play);
	}

	override function update(elapsed:Float):Void
	{
		if (player != null)
			player.update(elapsed * timeScale);

		super.update(elapsed);
	}

	override function destroy():Void
	{
		if (player != null)
		{
			player.dispose(true);
			player = null;
		}
			
		super.destroy();
	}

	@:noCompletion private function get_playing():Bool
		return player == null ? false : player.playing;

	@:noCompletion private function set_playing(value:Bool):Bool
		return player == null ? value : (player.playing = value);

	@:noCompletion private inline function get_animationEndHandler():Void->Void
		return player == null ? null : player.animationEndHandler;

	@:noCompletion private inline function set_animationEndHandler(value:Void->Void):Void->Void
		return player == null ? value : (player.animationEndHandler = value);

	@:noCompletion private inline function get_animationEndHandler():Void->Void
		return player == null ? null : player.animationEndHandler;

	@:noCompletion private inline function set_animationEndHandler(value:Void->Void):Void->Void
		return player == null ? value : (player.animationEndHandler = value);

	@:noCompletion private function get_frame():Int
		return player == null ? -1 : player.frame;

	@:noCompletion private function set_frame(value:Int):Int
		return player == null ? value : (player.frame = value);

	@:noCompletion private function get_framesCount():Int
		return player == null ? 0 : player.framesCount;
}
