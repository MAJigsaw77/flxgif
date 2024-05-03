/*
 * This work is licensed under MIT license.
 *
 * Copyright (C) 2014 Pavel "Yanrishatum" Alexandrov
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.yagp;

import com.yagp.structs.ExtensionFactory;
import com.yagp.structs.GifBytes;
import com.yagp.structs.GifFrame;
import com.yagp.structs.GifVersion;
import com.yagp.structs.GraphicsControl;
import com.yagp.structs.GraphicsDecoder;
import com.yagp.structs.ImageDescriptor;
import com.yagp.structs.LSD;
import com.yagp.structs.NetscapeExtension;
import haxe.io.Bytes;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.utils.ByteArray;
import openfl.Lib;
#if (target.threaded)
import sys.thread.Thread;
#end

/**
 * The GIF reader
 *
 * How to use: `var gif:Gif = GifDecoder.parseBytes(inputGifFile);`
 */
class GifDecoder
{
	// YAGP: Optimize overall program.

	/**
	 * Decodes Gif file from Bytes data stream.
	 *
	 * @param bytes Input file data stream.
	 *
	 * @return Decoded Gif file.
	 */
	public static function parseBytes(bytes:Bytes):Gif
	{
		var decoder:GifDecoder = new GifDecoder(new GifBytes(bytes));
		decoder.decodeGif();
		return decoder.gif;
	}

	/**
	 * Decodes Gif file from ByteArray data stream.
	 *
	 * Note: It just converts ByteArray to Bytes
	 *
	 * @param byteArray Input data stream.
	 *
	 * @return Decoded Gif file.
	 */
	public static inline function parseByteArray(byteArray:ByteArray):Gif
	{
		return parseBytes(cast(byteArray, Bytes));
	}

	/**
	 * Decodes Gif file from String.
	 *
	 * @param text Input String data.
	 *
	 * @return Decoded Gif file.
	 */
	public static inline function parseText(text:String):Gif
	{
		return parseBytes(Bytes.ofString(text));
	}

	/**
	 * Decodes Gif file from Bytes data stream asynchonously
	 *
	 * Note: Supported only threaded targets!
	 *
	 * @param bytes Input data stream.
	 * @param completeHandler Callback to which send decoded Gif file.
	 * @param errorHandler Callback to which send reports about occured error while decoding Gif file.
	 *
	 * @return true, if async decoding started successfully, false othervise.
	 */
	public static function parseBytesAsync(bytes:Bytes, completeHandler:Gif->Void, errorHandler:Dynamic->Void):Bool
	{
		#if (target.threaded)
		return new GifDecoder(new GifBytes(bytes)).decodeAsync(completeHandler, errorHandler);
		#else
		trace("Asynchronous parsing currently only supported on sys platforms.");

		return false;
		#end
	}

	/**
	 * Decodes Gif file from ByteArray data stream asynchonously
	 *
	 * Note: Supported only threaded targets!
	 *
	 * @param byteArray Input data stream.
	 * @param completeHandler Callback to which send decoded Gif file.
	 * @param errorHandler Callback to which send reports about occured error while decoding Gif file.
	 *
	 * @return true, if async decoding started successfully, false othervise.
	 */
	public static inline function parseByteArrayAsync(byteArray:ByteArray, completeHandler:Gif->Void, errorHandler:Dynamic->Void):Bool
	{
		#if (target.threaded)
		return parseBytesAsync(byteArray, completeHandler, errorHandler);
		#else
		trace("Asynchronous parsing currently only supported on sys platforms.");

		return false;
		#end
	}

	/**
	 * Decodes Gif file from String asynchonously
	 *
	 * Note: Supported only threaded targets!
	 *
	 * @param text Input String data.
	 * @param completeHandler Callback to which send decoded Gif file.
	 * @param errorHandler Callback to which send reports about occured error while decoding Gif file.
	 *
	 * @return true, if async decoding started successfully, false othervise.
	 */
	public static inline function parseTextAsync(text:String, completeHandler:Gif->Void, errorHandler:Dynamic->Void):Bool
	{
		#if (target.threaded)
		return parseBytesAsync(Bytes.ofString(text), completeHandler, errorHandler);
		#else
		trace("Asynchronous parsing currently only supported on sys platforms.");

		return false;
		#end
	}

	#if (target.threaded)
	private static var _asyncDecoders:Array<GifDecoder>;
	private static var _asyncDecoderChecker:Shape; // DisplayObject;

	private static function init():Void
	{
		_asyncDecoders = new Array();
		_asyncDecoderChecker = new Shape();
		_asyncDecoderChecker.addEventListener(Event.ENTER_FRAME, checkAsyncDecoders);
		_asyncDecoderChecker.visible = false;
		Lib.current.stage.addChild(_asyncDecoderChecker); // Assumption, that DisplayObject receives EnterFrame event even if it not in display list is incorrect.
	}

	private static function checkAsyncDecoders(e:Event):Void
	{
		var i:Int = 0;

		while (i < _asyncDecoders.length)
		{
			var dec:GifDecoder = _asyncDecoders[i];

			if (dec._done)
			{
				if (dec._completeHandler != null)
					dec._completeHandler(dec.gif);

				dec._completeHandler = null;
				dec._errorHandler = null;

				_asyncDecoders.remove(dec);
				continue;
			}
			else if (dec._error)
			{
				if (dec._errorHandler != null)
					dec._errorHandler(dec._errorMessage);

				dec._completeHandler = null;
				dec._errorHandler = null;

				_asyncDecoders.remove(dec);
				continue;
			}

			i++;
		}
	}
	#end

	/**
	 * Output GIF file with all data and frames
	 */
	public var gif:Gif;

	// Input stream
	private var _input:GifBytes;

	/** Input data stream */
	public var input(get, set):GifBytes;

	private inline function get_input():GifBytes
	{
		return _input;
	}

	private inline function set_input(v:GifBytes):GifBytes
	{
		return _input = v;
	}

	// Temporary data
	private var _graphicControlExtension:GraphicsControl;
	private var _globalColorTable:Array<Int>;

	// Async
	#if (target.threaded)
	private var _completeHandler:Gif->Void;
	private var _errorHandler:Dynamic->Void;
	private var _done:Bool;
	private var _error:Bool;
	private var _errorMessage:Dynamic;
	#end

	public function new(input:GifBytes = null)
	{
		this._input = input;
	}

	/**
	 * Start asynchronous decoding of input data stream.
	 *
	 * @param completeHandler Callback to which send decoded Gif file.
	 * @param errorHandler Callback to which send reports about occured error while decoding Gif file.
	 *
	 * @return true, if async decoding started successfully, false othervise.
	 */
	public function decodeAsync(completeHandler:Gif->Void, errorHandler:Dynamic->Void):Bool
	{
		#if (target.threaded)
		if (_input == null)
			return false;

		if (_asyncDecoders == null)
			init();

		this._done = false;
		this._error = false;
		this._completeHandler = completeHandler;
		this._errorHandler = errorHandler;

		_asyncDecoders.push(this);

		Thread.create(_decodeAsync);

		return true;
		#else
		trace("Asynchronous parsing currently only supported on sys platforms.");

		return false;
		#end
	}

	private function _decodeAsync():Void
	{
		#if (target.threaded)
		try
		{
			decodeGif();

			this._done = true;
		}
		catch (e:Dynamic)
		{
			this._error = true;
			this._errorMessage = e;
		}
		#end
	}

	/**
	 * Decodes Gif file.
	 */
	public function decodeGif():Gif
	{
		if (_input == null)
			return null;

		_input.position = 0;

		// Init GIF
		this.gif = new Gif();

		if (this.readHeader())
		{
			// Logic screen descriptor
			var lsd:LSD = new LSD(_input);

			this.gif.lsd = lsd;

			// Global color table
			if (lsd.globalColorTable) // Global CT
			{
				_globalColorTable = this.readColorTable(lsd.globalColorTableSize);
				if (lsd.backgroundColorIndex < _globalColorTable.length)
					this.gif.backgroundColor = _globalColorTable[lsd.backgroundColorIndex];
			}

			readBlock();

			_graphicControlExtension = null;
			_globalColorTable = null;
			_input = null;
		}
		else
		{
			throw "This is not a GIF file, or header invalid.";
		}

		return this.gif;
	}

	private function readBlock():Void
	{
		var id:Int;

		while (true)
		{
			id = _input.readByte();

			switch (id)
			{
				// Image descriptor / Image
				case 0x2C:
					readImage();
				// Extension block
				case 0x21:
					readExtension();
				// EOF
				case 0x3B:
					return;
			}
		}
	}

	private function readExtension():Void
	{
		switch (_input.readByte())
		{
			// Graphics control extension
			case 0xF9:
				#if yagp_strict_gif_version_check
				if (gif.version == GifVersion.GIF87a) // Yes, full specification support of 87a and 89a.
				{
					skipBlock();
					return;
				}
				#end

				_graphicControlExtension = new GraphicsControl(_input);
			// Program extension block
			case 0xFF:
				readApplicationExtension();
			default:
				skipBlock();
		}
	}

	private function readApplicationExtension():Void
	{
		#if yagp_strict_gif_version_check
		if (gif.version == GifVersion.GIF87a)
		{
			skipBlock();
			return;
		}
		#end

		// Extension name
		_input.position++; // Skip block size (0x0B);

		var name:String = _input.readUTFBytes(8);
		var version:String = _input.readUTFBytes(3);

		switch (name)
		{
			// Netscape 2.0 - animation looping
			// YAGP: Make correct netscape extension reading. Currently it can be both Looping or Buffering.
			case "NETSCAPE":
				gif.netscape = new NetscapeExtension(_input);

			// Make next extension reading:
			// PIANYGIF1.0
			// Netscape Buffering Application Extension
			// AnimExts Looping Application Extension (ANIMEXTS1.0)
			default:
				skipBlock();
		}
	}

	private function readImage():Void
	{
		// Reading descriptor block
		var imageDescriptor:ImageDescriptor = new ImageDescriptor(_input);

		// Color table set
		var table:Array<Int> = _globalColorTable;

		if (imageDescriptor.localColorTable)
			table = this.readColorTable(imageDescriptor.localColorTableSize);

		if (table == null)
		{
			throw "Image didn't have color table!";
			return;
		}

		// Reading graphics data;
		var decoder:GraphicsDecoder = new GraphicsDecoder(_input, imageDescriptor);

		// Make new GifFrame
		var gifFrame:GifFrame = new GifFrame(table, imageDescriptor, decoder, _graphicControlExtension);

		gif.frames.push(gifFrame);

		// And clear
		table = null;
		decoder = null;
		_graphicControlExtension = null;
	}

	// =======================================================
	// { Reading not heavy-structural blocks
	// =======================================================

	/**
	 * Reads header of GIF file.
	 * @return true, if header is valid, false otherwise.
	 */
	private function readHeader():Bool
	{
		// Is header valid?
		var valid:Bool = _input.readUTFBytes(3) == "GIF";

		if (valid)
		{
			var version:String = _input.readUTFBytes(3);

			if (version == "87a")
				this.gif.version = GifVersion.GIF87a;
			else if (version == "89a")
				this.gif.version = GifVersion.GIF89a;

			if (this.gif.version == null)
			{
				// trace("Unknown GIF version \"" + this.gif.version + "\"! Selected default (89a) version.");
				this.gif.version = GifVersion.GIF89a;
			}
		}
		return valid;
	}

	/**
	 * Reads color table.
	 * Structure of Color Tables:
	 * RRGGBB RRGGBB RRGGBB
	 *
	 * @param colorsCount Count of colors in color table.
	 *
	 * @return Vector.<uint> with readed colors.
	 */
	private function readColorTable(colorsCount:Int):Array<Int>
	{
		var result:Array<Int> = new Array<Int>();

		for (i in 0...colorsCount)
		{
			result[i] = 0xFF000000 | // A
				_input.readByte() << 16 | // R
					_input.readByte() << 8 | // G
						_input.readByte(); // B
		}

		return result;
	}

	// =======================================================
	// }
	// =======================================================

	/**
	 * Utils; Skips blocks array
	 */
	private function skipBlock():Void
	{
		var blockSize:Int = 0;

		do
		{
			blockSize = _input.readByte();
			_input.position += blockSize;
		}
		while (blockSize != 0);
	}
}
