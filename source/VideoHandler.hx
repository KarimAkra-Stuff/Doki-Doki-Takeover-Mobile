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
		super(true);

		// autoVolumeHandle = false;
		onEndReached.add(function()
		{
			dispose();
		});
	}

	override public function play():Bool
	{
		// FlxG.stage.quality = BEST;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.sound.music.stop();
		FlxG.addChildBelowMouse(this);
		// make the video look a bit cleaner ig..?
		shader = new openfl.filters.BitmapFilterShader();
		@:privateAccess
		if(shader != null)
		{
			trace('video shader is not null');
			@:privateAccess
			shader.__texture.filter = SaveData.globalAntialiasing ? LINEAR : NEAREST;
		}
		return super.play();
	}

	override public function dispose():Void
	{
		// FlxG.stage.quality = LOW;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
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
