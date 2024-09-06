package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class Main extends Sprite
{
	var game:FlxGame;
	var gameWidth:Int = 1280; // Width of the game in pixels
	var gameHeight:Int = 720; // Height of the game in pixels
	var initialState:Class<FlxState> = Init; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPSCounter;
	public static var tongue:FireTongueEx;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		#if android
		Sys.setCwd(haxe.io.Path.addTrailingSlash(android.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.documentsDirectory);
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if linux
		startFullscreen = isSteamDeck();
		#end

		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / game.zoom);
			gameHeight = Math.ceil(stageHeight / game.zoom);
		}
		#else
		if (zoom == -1.0)
			zoom = 1.0;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);

		if (fpsVar != null)
			fpsVar.visible = SaveData.showFPS;

		#if CRASH_HANDLER
		CrashHandler.init();
		#end

		#if FEATURE_MP4
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua' #if windows ,'--aout=waveout' #end] #end);
		#end

		// Finish up loading debug tools.
		// NOTE: Causes Hashlink to crash, so it's disabled.
		#if !hl
		Debug.onGameStart();
		#end
		mobile.MobileData.init();

		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsVar != null)
				fpsVar.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));

		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		#if web
		FlxG.keys.preventDefaultKeys.push(TAB);
		#else
		FlxG.keys.preventDefaultKeys = [TAB];
		#end
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end
	}

	static function resetSpriteCache(sprite:Sprite) {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	inline public static function isSteamDeck():Bool
	{
		#if linux
		return Sys.environment()["USER"] == "deck";
		#else
		return false;
		#end
	}

	inline public static function alertPopup(desc:String, title:String = 'Error!')
	{
		#if (android && !macro)
		android.Tools.showAlertDialog(title, desc, {name: 'ok', func: null});
		#else
		FlxG.stage.window.alert(desc, title);
		#end
	}
}
