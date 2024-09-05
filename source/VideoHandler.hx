#if FEATURE_MP4
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import hxvlc.flixel.FlxVideo;
import openfl.events.KeyboardEvent;

class VideoHandler extends FlxVideo
{
	public var canSkip:Bool = false;
	public var skipKeys:Array<FlxKey> = [];

	public function new():Void
	{
		super();

		// autoVolumeHandle = false;
		onEndReached.add(function()
		{
			dispose();
		});
	}

	override public function play():Bool
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = false;
		FlxG.sound.music.stop();
		FlxG.addChildBelowMouse(this);

		return super.play();
	}

	override public function dispose():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = true;
		FlxG.removeChild(this);
		super.dispose();
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!canSkip)
			return;

		if (skipKeys.contains(event.keyCode))
		{
			canSkip = false;
			onEndReached.dispatch();
		}
	}
}
#end
