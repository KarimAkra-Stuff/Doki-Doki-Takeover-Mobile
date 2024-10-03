package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import mobile.MobileData;
import mobile.MobileScaleMode;
import openfl.Assets;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.io.BytesInput;
import haxe.zip.*;
#if android
import android.content.Context;
import android.Tools;
#end

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";

	public final function getName()
	{
		return _name;
	}

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	public function getValue():String
	{
		return throw "stub!";
	}

	public function left():Bool
	{
		return throw "stub!";
	}

	public function right():Bool
	{
		return throw "stub!";
	}
}

class KeyBindingsOption extends Option
{
	private var controls:Controls;

	public function new(desc:String, controls:Controls)
	{
		super();
		description = desc;
		this.controls = controls;
	}

	public override function press():Bool
	{
		OptionsState.instance.openSubState(new KeyBindSubstate());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameKeyBindings', 'option');
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.downScroll = !SaveData.downScroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return SaveData.downScroll ? LangUtil.getString('nameDownscroll', 'option') : LangUtil.getString('nameUpscroll', 'option');
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.ghostTapping = !SaveData.ghostTapping;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return SaveData.ghostTapping ? LangUtil.getString('nameGhostTap', 'option') : LangUtil.getString('nameNoGhostTap', 'option');
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.accuracyDisplay = !SaveData.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('cmnAccuracy') + ' ' + (SaveData.accuracyDisplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.songPosition = !SaveData.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('namePosition', 'option') + ' ' + (SaveData.songPosition ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.noReset = !SaveData.noReset;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameReset', 'option') + ' ' + (!SaveData.noReset ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.flashing = !SaveData.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameFlashing', 'option') + ' ' + (SaveData.flashing ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		OptionsState.instance.openSubState(new JudgementSubstate());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameJudgement', 'option');
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.showFPS = !SaveData.showFPS;
		Main.fpsVar.visible = SaveData.showFPS;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return return LangUtil.getString('nameFPSCount', 'option') + ' ' + (SaveData.showFPS ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameFPSCap', 'option');
	}

	override function right():Bool
	{
		SaveData.framerate += 1;

		if (SaveData.framerate < 60)
			SaveData.framerate = 60;
		else if (SaveData.framerate > 330)
			SaveData.framerate = 330;

		CoolUtil.setFPSCap(SaveData.framerate);

		return true;
	}

	override function left():Bool
	{
		SaveData.framerate -= 1;

		if (SaveData.framerate < 60)
			SaveData.framerate = 60;
		else if (SaveData.framerate > 330)
			SaveData.framerate = 330;

		CoolUtil.setFPSCap(SaveData.framerate);

		return true;
	}

	override function getValue():String
	{
		return LangUtil.getString('descCurFPSCap', 'option') + ': ' + SaveData.framerate;
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameScroll', 'option');
	}

	override function right():Bool
	{
		SaveData.scrollSpeed += 0.1;

		if (SaveData.scrollSpeed < 0.9)
			SaveData.scrollSpeed = 0.9;

		if (SaveData.scrollSpeed > 4)
			SaveData.scrollSpeed = 4;

		return true;
	}

	override function left():Bool
	{
		SaveData.scrollSpeed -= 0.1;

		if (SaveData.scrollSpeed < 0.9)
			SaveData.scrollSpeed = 0.9;

		if (SaveData.scrollSpeed > 4)
			SaveData.scrollSpeed = 4;

		return true;
	}

	override function getValue():String
	{
		var visualValue:String = SaveData.scrollSpeed < 1 ? LangUtil.getString('nameScrollDefault', 'option') : Std.string(FlxMath.roundDecimal(SaveData.scrollSpeed, 1));
		return LangUtil.getString('descCurScroll', 'option') + ': ' + visualValue;
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.npsDisplay = !SaveData.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameNPS', 'option') + ' ' + (SaveData.npsDisplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		MusicBeatState.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameCustomize', 'option');
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.botplay = !SaveData.botplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return LangUtil.getString('cmnBotplay') + ' ' + (SaveData.botplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
}

class GFCountdownOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.gfCountdown = !SaveData.gfCountdown;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return LangUtil.getString('nameGFCountdown', 'option') + ' ' + (SaveData.gfCountdown ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
}

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		SaveData.middleScroll = !SaveData.middleScroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (SaveData.middleScroll ? LangUtil.getString('nameMiddleScrollOn', 'option') : LangUtil.getString('nameMiddleScrollOff', 'option'));
	}

	override function left():Bool
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		SaveData.middleOpponent = !SaveData.middleOpponent;
		return true;
	}

	override function right():Bool
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		SaveData.middleOpponent = !SaveData.middleOpponent;
		return true;
	}

	override function getValue():String
	{
		return LangUtil.getString('descMiddleOpponent', 'option') + ': ' + (SaveData.middleOpponent ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		SaveData.laneUnderlay = !SaveData.laneUnderlay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (SaveData.laneUnderlay ? LangUtil.getString('nameLaneUnderwayOn', 'option') : LangUtil.getString('nameLaneUnderwayOff', 'option'));
	}

	override function right():Bool
	{
		SaveData.laneTransparency += 0.05;

		if (SaveData.laneTransparency < 0)
			SaveData.laneTransparency = 0;

		if (SaveData.laneTransparency > 1)
			SaveData.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		SaveData.laneTransparency -= 0.05;

		if (SaveData.laneTransparency < 0)
			SaveData.laneTransparency = 0;

		if (SaveData.laneTransparency > 1)
			SaveData.laneTransparency = 1;

		return true;
	}

	override function getValue():String
	{
		return LangUtil.getString('descLaneUnderwayControl', 'option') + ': ${FlxMath.roundDecimal(SaveData.laneTransparency, 2) * 100}%';
	}
}

class HitSoundOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		SaveData.hitSound = !SaveData.hitSound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameHitSound', 'option') + ' ' + (SaveData.hitSound ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}

	override function right():Bool
	{
		SaveData.hitSoundVolume += 0.1;

		if (SaveData.hitSoundVolume < 0)
			SaveData.hitSoundVolume = 0;

		if (SaveData.hitSoundVolume > 1)
			SaveData.hitSoundVolume = 1;

		FlxG.sound.play(Paths.sound('hitsound/snap'), SaveData.hitSoundVolume);

		return true;
	}

	override function left():Bool
	{
		SaveData.hitSoundVolume -= 0.1;

		if (SaveData.hitSoundVolume < 0)
			SaveData.hitSoundVolume = 0;

		if (SaveData.hitSoundVolume > 1)
			SaveData.hitSoundVolume = 1;

		FlxG.sound.play(Paths.sound('hitsound/snap'), SaveData.hitSoundVolume);

		return true;
	}

	override function getValue():String
	{
		return LangUtil.getString('descHitSoundControl', 'option') + ': ${FlxMath.roundDecimal(SaveData.hitSoundVolume, 1) * 100}%';
	}
}

class HitSoundJudgements extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.judgeHitSound = !SaveData.judgeHitSound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return LangUtil.getString('nameHitSoundJudge', 'option') + ' ' + (SaveData.judgeHitSound ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
}

class ResetSave extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		// ensure that we're erasing (hopefully)
		if (FlxG.save.data == null)
			FlxG.save.bind('DokiTakeover', SaveData.getSavePath());

		FlxG.save.erase();
		Sys.exit(0);

		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? LangUtil.getString('nameSaveResetConfirm', 'option') : LangUtil.getString('nameSaveReset', 'option');
	}
}

class ResetScore extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		SaveData.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}

		SaveData.songCombos = null;
		for (key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}

		SaveData.songAccuracies = null;
		for (key in Highscore.songAccuracies.keys())
		{
			Highscore.songAccuracies[key] = 0;
		}

		SaveData.save();

		MusicBeatState.resetState();

		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? LangUtil.getString('nameScoreResetConfirm', 'option') : LangUtil.getString('nameScoreReset', 'option');
	}
}

class ResetStory extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		SaveData.unlockAll(false);
		SaveData.save();

		MusicBeatState.switchState(new MainMenuState());

		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? LangUtil.getString('nameStoryResetConfirm', 'option') : LangUtil.getString('nameStoryReset', 'option');
	}
}

#if FEATURE_OBS
class SelfAwareness extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.selfAware = !SaveData.selfAware;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameSelfAware', 'option') + ' ' + (SaveData.selfAware ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}
#end

#if FEATURE_GAMEJOLT
class GameJolt extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		MusicBeatState.switchState(new GameJolt.GameJoltLogin());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameGameJolt', 'option');
	}
}
#end

class NoteSplashToggle extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.noteSplash = !SaveData.noteSplash;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameNoteSplash', 'option') + ' ' + (SaveData.noteSplash ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class EarlyLateOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.earlyLate = !SaveData.earlyLate;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameEarlyLate', 'option') + ' ' + (SaveData.earlyLate ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class BadEnd extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		#if (DOWNLOAD_OPTION && android)
		var dir:String = Path.addTrailingSlash(Context.getExternalFilesDir());
		var apkPath:String = "mobile:assets/mobile/BadEnding-release.apk";
		var appPath:String = Path.join([dir, "game.apk"]);
		if(!FileSystem.exists(appPath))
		{
			trace('APK File does not exist, extracting it right now!');
			trace('Extracting $apkPath to $appPath');
			File.saveBytes(appPath, Assets.getBytes(apkPath));
		}
		trace('requesting the installation of the APK..');
		Tools.installPackage(appPath);
		#else
		CoolUtil.openURL('https://gamebanana.com/mods/386603');
		MusicBeatState.resetState();
		#end
		return false;
	}

	private override function updateDisplay():String
	{
		return 'BAD ENDING';
	}
}

/*
class VideoDub extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		CoolUtil.openURL('https://www.youtube.com/watch?v=qa93UKQqoqs');
		MusicBeatState.resetState();
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameVideoDub', 'option');
	}
}
*/

class AutoPause extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.autoPause = !SaveData.autoPause;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameAutoPause', 'option') + ' ' + (SaveData.autoPause ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

#if FEATURE_UNLOCK
class UnlockAll extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.unlockAll();
		MusicBeatState.switchState(new MainMenuState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Unlock All";
	}
}
#end

class JudgementCounter extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.judgementCounter = !SaveData.judgementCounter;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameJudgeCount', 'option') + ' ' + (SaveData.judgementCounter ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

#if FEATURE_LANGUAGE
class LanguageSelection extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		MusicBeatState.switchState(new LangSelectState());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('cmnLanguage');
	}
}
#end

class RatingToggle extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.ratingToggle = !SaveData.ratingToggle;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (SaveData.ratingToggle ? LangUtil.getString('nameShowRating', 'option') : LangUtil.getString('nameHideRating', 'option'));
	}
}

class AntiAliasing extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.globalAntialiasing = !SaveData.globalAntialiasing;
		display = updateDisplay();

		for (member in OptionsState.instance.members)
		{
			var member:Dynamic = member;

			if (member != null && (member is FlxSprite || member is FlxText))
				member.antialiasing = SaveData.globalAntialiasing;
		}

		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameAntialiasing', 'option') + ' ' + (SaveData.globalAntialiasing ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class GPUTextures extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.gpuTextures = !SaveData.gpuTextures;
		hxvlc.openfl.Video.useTexture = SaveData.gpuTextures;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameGPUTextures', 'option') + ' ' + (SaveData.gpuTextures ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class SongCacheOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.cacheSong = !SaveData.cacheSong;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameCacheSong', 'option') + ' ' + (SaveData.cacheSong ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class CacheState extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		MusicBeatState.switchState(new CachingState());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameCache', 'option');
	}
}

class Shaders extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.shaders = !SaveData.shaders;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameShaders', 'option') + ' ' + (SaveData.shaders ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class LowEnd extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.lowEnd = !SaveData.lowEnd;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameLowEnd', 'option') + ' ' + (SaveData.lowEnd ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class CustomCursor extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.customCursor = !SaveData.customCursor;
		FlxG.mouse.useSystemCursor = !SaveData.customCursor;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('nameCursor', 'option') + ' ' + (SaveData.customCursor ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class HitboxTypeOption extends Option
{
	public var typesList:Array<String> = ['Gradient', 'Solid Color', 'Hidden'];
	public var curType:Int = 0;
	
	public function new(desc:String)
	{
		super();
		description = desc;
		curType = typesList.indexOf(SaveData.hitboxType);
	}

	public override function press():Bool
	{
		if(curType == 2)
			curType = 0;
		else
			curType++;
		SaveData.hitboxType = typesList[curType];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Hitbox Designe: " + SaveData.hitboxType;
	}
}

class HitboxAlphaOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return 'Hitbox Opacity';
	}

	override function right():Bool
	{
		SaveData.hitboxAlpha += 0.01;

		if (SaveData.hitboxAlpha > 1)
			SaveData.hitboxAlpha = 1;
		else if (SaveData.hitboxAlpha < 0.01)
			SaveData.hitboxAlpha = 0.01;

		return true;
	}

	override function left():Bool
	{
		SaveData.hitboxAlpha -= 0.01;

		if (SaveData.hitboxAlpha > 1)
			SaveData.hitboxAlpha = 1;
		else if (SaveData.hitboxAlpha < 0.01)
			SaveData.hitboxAlpha = 0.01;

		return true;
	}

	override function getValue():String
	{
		return "Current Hitbox Opacity" + ': ${Math.fround(SaveData.hitboxAlpha * 100)}%';
	}
}

class TouchPadAlphaOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return 'Touch Pad Opacity';
	}

	override function right():Bool
	{
		SaveData.touchPadAlpha += 0.01;

		if (SaveData.touchPadAlpha > 1)
			SaveData.touchPadAlpha = 1;
		else if (SaveData.touchPadAlpha < 0.01)
			SaveData.touchPadAlpha = 0.01;

		if (MusicBeatState.instance != null)
			MusicBeatState.instance.touchPad.alpha = SaveData.touchPadAlpha;

		return true;
	}

	override function left():Bool
	{
		SaveData.touchPadAlpha -= 0.01;

		if (SaveData.touchPadAlpha > 1)
			SaveData.touchPadAlpha = 1;
		else if (SaveData.touchPadAlpha < 0.01)
			SaveData.touchPadAlpha = 0.01;

		if(MusicBeatState.instance != null)
			MusicBeatState.instance.touchPad.alpha = SaveData.touchPadAlpha;

		return true;
	}

	override function getValue():String
	{
		return "Current Touch Pad Opacity" + ': ${Math.fround(SaveData.touchPadAlpha * 100)}%';
	}
}

class MobileControlsOption extends Option
{
	public var modesList:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Hitbox'];
	@:isVar
	public var curType(get, set):Int;

	public function new(desc:String)
	{
		super();
		description = desc;
		// acceptValues = true;
	}

	public override function press():Bool
	{
		changeType(1);
		display = updateDisplay();
		return true;
	}

	// tried to make it work by pressing left and right but didn't turn out well

	// override function right():Bool
	// {
	// 	changeType(1);
	// 	// display = updateDisplay();
	// 	press();
	// 	return true;
	// }

	// override function left():Bool
	// {
	// 	changeType(-1);
	// 	// display = updateDisplay();
	// 	press();

	// 	return true;
	// }

	private override function updateDisplay():String
	{
		return "Mobile Controls: " + modesList[curType];
	}

	function changeType(change:Int = 0)
	{
		curType += change;

		if (curType < 0)
			curType = modesList.length - 1;
		if (curType >= modesList.length)
			curType = 0;

	}

	private function get_curType():Int
	{
		return MobileData.mode;
	}

	private function set_curType(Value:Int):Int
	{
		return MobileData.mode = Value;
	}

	// override function getValue():String
	// {
	// 	return "Mobile Options";
	// }
}

class CustomPadSetup extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		MusicBeatState.switchState(new mobile.TouchPadMappingState());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Customize Touch Pad Layout";
	}
}

class WideScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.wideScreen = !SaveData.wideScreen;
		FlxG.scaleMode = new MobileScaleMode();
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return return 'Wide Screen: ' + (SaveData.wideScreen ? 'On' :'Off');
	}
}

class ScreenSaver extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SaveData.screensaver = !SaveData.screensaver;
		lime.system.System.allowScreenTimeout = SaveData.screensaver;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return return 'Screen Saver: ' + (SaveData.screensaver ? 'On' : 'Off');
	}
}