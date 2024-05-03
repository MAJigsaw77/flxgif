package;

import flixel.FlxG;
import flixel.FlxState;
import flxgif.FlxGifBackdrop;
import flxgif.FlxGifSprite;

class PlayState extends FlxState
{
	override function create():Void
	{
		FlxG.cameras.bgColor = 0xFF131C1B;

		var spamton:FlxGifBackdrop = new FlxGifBackdrop('assets/Spamton_overworld_laughing.gif', XY, 0, 0);
		spamton.velocity.set(-40, -40);
		spamton.antialiasing = true;
		add(spamton);

		super.create();
	}
}
