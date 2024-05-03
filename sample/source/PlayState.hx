package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flxgif.FlxGifBackdrop;
import flxgif.FlxGifSprite;
import openfl.utils.Assets;
import openfl.utils.ByteArray;

class PlayState extends FlxState
{
	override function create():Void
	{
		FlxG.cameras.bgColor = 0xFF131C1B;

		var loading:FlxText = new FlxText(0, 0, FlxG.width - 20, 'Loading...', 48);
		loading.setBorderStyle(OUTLINE, FlxColor.BLACK);
		loading.active = false;
		loading.screenCenter();
		loading.antialiasing = true;
		add(loading);

		super.create();

		Assets.loadBytes('assets/Spamton_overworld_laughing.gif').onComplete(function(bytes:ByteArray):Void
		{
			loading.visible = false;

			var spamton:FlxGifBackdrop = new FlxGifBackdrop(XY, 0, 0);
			spamton.antialiasing = true;
			spamton.loadGif(bytes);
			spamton.screenCenter();
			add(spamton);
		});
	}
}
