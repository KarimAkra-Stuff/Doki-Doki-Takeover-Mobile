package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import mobile.*;

class MusicBeatState extends FlxUIState
{
	public static var instance:MusicBeatState;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;


	public var touchPad:TouchPad;
	public var mobileControls:MobileControls;

	public var touchPadCamera:FlxCamera;
	public var mobileControlsCamera:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cursor'));
		FlxG.mouse.load(sprite.pixels);

		CoolUtil.setFPSCap(SaveData.framerate);

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;

		// Advance the random seed.
		Random.advance();

		instance = this;
		super.create();
	}

	override function update(elapsed:Float)
	{
		var nextStep:Int = updateCurStep();

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
		removeTouchPad();
		removeMobileControls();

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

		if(touchPad != null)
			touchPad.cameras = [FlxG.camera];

		FlxG.cameras.remove(touchPadCamera);
		touchPadCamera = FlxDestroyUtil.destroy(touchPadCamera);
	}

	public function addMobileControls():MobileControls
	{
		switch (MobileData.mode)
		{
			case 0: // RIGHT_FULL
				mobileControls = new TouchPad('RIGHT_FULL', 'NONE');
			case 1: // LEFT_FULL
				mobileControls = new TouchPad('LEFT_FULL', 'NONE');
			case 2: // CUSTOM
				mobileControls = MobileData.getTouchPadCustomMode(new TouchPad('RIGHT_FULL', 'NONE'));
			case 3: // HITBOX
				mobileControls = new Hitbox();
		}

		mobileControlsCamera = new FlxCamera();
		mobileControlsCamera.bgColor.alpha = 0;
		FlxG.cameras.add(mobileControlsCamera, false);
		mobileControls.instance.cameras = [mobileControlsCamera];

		add(mobileControls.instance);
		return mobileControls;
	}

	public function removeMobileControls():Void
	{
		if (mobileControls != null)
		{
			remove(mobileControls.instance);
			mobileControls.instance = FlxDestroyUtil.destroy(mobileControls.instance);
			mobileControls = null;
		}

		if(mobileControlsCamera != null)
		{
			FlxG.cameras.remove(mobileControlsCamera);
			mobileControlsCamera = FlxDestroyUtil.destroy(mobileControlsCamera);
		}

	}

	public static function switchState(nextState:FlxState)
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
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
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
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
