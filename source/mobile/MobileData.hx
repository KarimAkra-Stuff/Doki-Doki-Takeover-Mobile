package mobile;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;

using StringTools;

/**
 * A class that handels mobile controls related data.
 * @author: Karim Akra
 */
class MobileData
{
	public static var actionModes:Map<String, TouchPadButtonsData> = new Map();
	public static var dpadModes:Map<String, TouchPadButtonsData> = new Map();

	public static function init()
	{
		readDirectory(Paths.getLibraryPath('DPadModes', "mobile"), dpadModes);
		readDirectory(Paths.getLibraryPath('ActionModes', "mobile"), actionModes);
		// shit is meant for psych and not kade soo fuck it
		// #if FEATURE_FILESYSTEM
		// for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'mobile/'))
		// {
		// 	readDirectory(Path.join([folder, 'DPadModes']), dpadModes);
		// 	readDirectory(Path.join([folder, 'ActionModes']), actionModes);
		// }
		// #end
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		#if FEATURE_FILESYSTEM if(FileSystem.exists(folder)) #end
			for (file in readDir(folder))
			{
				var fileWithNoLib:String = file.contains(':') ? file.split(':')[1] : file;
				if (Path.extension(fileWithNoLib) == 'json')
				{
				 	#if FEATURE_FILESYSTEM file = Path.join([folder, Path.withoutDirectory(file)]); #end
					var str = #if FEATURE_FILESYSTEM File.getContent(file) #else Assets.getText(file) #end;
					var json:TouchPadButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(fileWithNoLib));
					map.set(mapKey, json);
				}
			}
	}

    public static function readDir(directory:String):Array<String>
	{
		#if FEATURE_FILESYSTEM
		return FileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
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
		#end
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
	color:String // the button color, default color is white.
}