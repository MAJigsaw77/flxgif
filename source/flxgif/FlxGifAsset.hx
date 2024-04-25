package flxgif;

import flixel.util.typeLimit.OneOfThree;
import openfl.utils.ByteArray;
import haxe.io.Bytes;

typedef FlxGifAsset = OneOfThree<ByteArrayData, Bytes, String>;