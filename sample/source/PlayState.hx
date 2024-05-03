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

		Assets.loadBytes('assets/nikki.gif').onComplete(function(bytes:ByteArray):Void
		{
			loading.visible = false;

			var nikki:FlxGifSprite = new FlxGifSprite(0, 0);
			nikki.antialiasing = true;
			nikki.loadGif(bytes);
			nikki.screenCenter();
			add(nikki);
		});

		super.create();
	}
}
