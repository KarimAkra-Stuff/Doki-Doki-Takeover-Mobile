package mobile;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;

using StringTools;

/**
 * A class that handels mobile controls related data.
 * @author: Karim Akra
 */
class MobileData
{
	public static var actionModes:Map<String, TouchPadButtonsData> = new Map();
	public static var dpadModes:Map<String, TouchPadButtonsData> = new Map();
	public static var buttonsListIDs:Map<String, MobileButtonsList> = new Map();
	public static var save:FlxSave = new FlxSave();
	public static var mode(get, set):Int;

	public static function init()
	{
		readDirectory(Paths.getLibraryPath('DPadModes', "mobile"), dpadModes);
		readDirectory(Paths.getLibraryPath('ActionModes', "mobile"), actionModes);

		for (data in MobileButtonsList.createAll())
			buttonsListIDs.set(data.getName(), data);

		save.bind('MobileControls', SaveData.getSavePath());
	}

	public static function setTouchPadCustomMode(touchPad:TouchPad):Void
	{
		if (save.data.buttons == null)
		{
			save.data.buttons = new Array();
			for (buttons in touchPad)
				save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in touchPad)
			{
				save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		save.flush();
	}

	public static function getTouchPadCustomMode(touchPad:TouchPad):TouchPad
	{
		var tempCount:Int = 0;

		if (save.data.buttons == null)
			return touchPad;

		for (buttons in touchPad)
		{
			if (save.data.buttons[tempCount] != null)
			{
				buttons.x = save.data.buttons[tempCount].x;
				buttons.y = save.data.buttons[tempCount].y;
			}
			tempCount++;
		}

		return touchPad;
	}

	static function set_mode(mode:Int = 3)
	{
		save.data.mobileControlsMode = mode;
		save.flush();
		return mode;
	}

	static function get_mode():Int
	{
		if (save.data.mobileControlsMode == null)
		{
			save.data.mobileControlsMode = 3;
			save.flush();
		}

		return save.data.mobileControlsMode;
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		for (file in readDir(folder))
		{
			var fileWithNoLib:String = file.contains(':') ? file.split(':')[1] : file;
			if (Path.extension(fileWithNoLib) == 'json')
			{
			 	// #if FEATURE_FILESYSTEM file = Path.join([folder, Path.withoutDirectory(file)]); #end
				// var str = #if FEATURE_FILESYSTEM File.getContent(file); #else Assets.getText(file); #end
				var str = Assets.getText(file);
				var json:TouchPadButtonsData = cast Json.parse(str);
				var mapKey:String = Path.withoutDirectory(Path.withoutExtension(fileWithNoLib));
				map.set(mapKey, json);
			}
		}
	}

    public static function readDir(directory:String):Array<String>
	{
		var directoryWithNoLib:String = directory.contains(':') ? directory.split(':')[1] : directory;
		// #if FEATURE_FILESYSTEM
		// return FileSystem.readDirectory(directoryWithNoLib);
		// #else
		var dirs:Array<String> = [];
		for (dir in Assets.list().filter(folder -> folder.startsWith(directoryWithNoLib)))
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
					dirs.push('$library:$dir');
				else if(Assets.exists(dir) && !dirs.contains(dir))
					dirs.push(dir);
			}
		}
		return dirs;
		// #end
	}
}

typedef TouchPadButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef ButtonsData =
{
	button:String, // what TouchButton should be used, must be a valid TouchButton var from TouchPad as a string.
	graphic:String, // the graphic of the button, usually can be located in the TouchPad xml .
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	color:String, // the button color, default color is white.
	id:Array<String> // should be a MobileButtonsList value as a string.
}