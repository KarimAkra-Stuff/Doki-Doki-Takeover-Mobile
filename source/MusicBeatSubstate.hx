package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Lib;
import mobile.*;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	public var prevInstance:MusicBeatSubstate;

	public function new()
	{
		// CoolUtil.setFPSCap(SaveData.framerate);
		if(instance != null)
			prevInstance = instance;
		instance = this;
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	public var touchPad:TouchPad;
	public var touchPadCamera:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		// everyStep();
		var nextStep = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				// Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		// if (CoolUtil.getFPSCap() != SaveData.framerate)
		// 	CoolUtil.setFPSCap(SaveData.framerate);

		// let's improve performance of this a tad
		if (FlxG.autoPause != SaveData.autoPause)
			FlxG.autoPause = SaveData.autoPause;

		super.update(elapsed);
	}

	override public function destroy()
	{
		if (prevInstance != null)
			instance = prevInstance;
		
		removeTouchPad();

		super.destroy();
	}

	public function addTouchPad(dpadMode:String, actionMode:String):TouchPad
	{
		if (touchPad != null)
			removeTouchPad();

		touchPad = new TouchPad(dpadMode, actionMode);
		add(touchPad);

		return touchPad;
	}

	public function removeTouchPad():Void
	{
		removeTouchPadCamera();

		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}
	}

	public function addTouchPadCamera():Void
	{
		if (touchPad == null)
			return;

		touchPadCamera = new FlxCamera();
		FlxG.cameras.add(touchPadCamera, false);
		touchPadCamera.bgColor.alpha = 0;
		touchPad.cameras = [touchPadCamera];
	}

	public function removeTouchPadCamera():Void
	{
		if (touchPadCamera == null)
			return;

		if (touchPad != null)
			touchPad.cameras = [FlxG.camera];

		FlxG.cameras.remove(touchPadCamera);
		touchPadCamera = FlxDestroyUtil.destroy(touchPadCamera);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
