package mobile;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import flixel.tweens.*;
import openfl.display.BitmapData;
import mobile.TouchButton;
import openfl.display.Shape;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Mihai Alexandru and Karim Akra
 */
class Hitbox extends FlxTypedSpriteGroup<HitboxButton>
{
	public var buttonLeft:HitboxButton = new HitboxButton(0, 0);
	public var buttonDown:HitboxButton = new HitboxButton(0, 0);
	public var buttonUp:HitboxButton = new HitboxButton(0, 0);
	public var buttonRight:HitboxButton = new HitboxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new()
	{
		super();

		add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
		add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
		add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));
			
		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), HitboxButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):HitboxButton
	{
		var hint = new HitboxButton(X, Y, Width, Height);
		hint.color = Color;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}

class HitboxButton extends TouchButton
{
	public function new(x:Float, y:Float, ?width:Int, ?height:Int)
    {
		super(x, y);

		if(width == null || height == null)
			return;
        
        loadGraphic(createHintGraphic(width, height));

		if (SaveData.hitboxType != "Hidden")
		{
    		var hintTween:FlxTween = null;
			onDown.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				hintTween = FlxTween.tween(this, {alpha: SaveData.controlsAlpha}, SaveData.controlsAlpha / 100, {
					ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						hintTween = null;
					}
				});
			}
			onUp.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				hintTween = FlxTween.tween(this, {alpha: 0.00001}, SaveData.controlsAlpha / 10, {
					ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						hintTween = null;
					}
				});
			}
			onOut.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				hintTween = FlxTween.tween(this, {alpha: 0.00001}, SaveData.controlsAlpha / 10, {
					ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						hintTween = null;
					}
				});
			}
		}

        statusAlphas = [];
		statusIndicatorType = NONE;
		solid = false;
		immovable = true;
		multiTouch = true;
		moves = false;
		antialiasing = SaveData.globalAntialiasing;
		alpha = 0.00001;
	}

	function createHintGraphic(Width:Int, Height:Int):FlxGraphic
	{
		var guh = SaveData.controlsAlpha;
        
		if (guh >= 0.9)
			guh = guh - 0.1;
        
        var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);

		if (SaveData.hitboxType == 'Gradient')
        {
			shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}
        else
        {
			shape.graphics.lineStyle(10, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
        
		return FlxG.bitmap.add(bitmap);
	}
}
