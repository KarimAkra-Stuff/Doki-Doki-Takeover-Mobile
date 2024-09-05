package mobile;

import mobile.TouchButton;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import haxe.io.Path;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

/**
 * ...
 * @author: Karim Akra and Lily Ross (mcagabe19)
 */
class TouchPad extends FlxTypedSpriteGroup<TouchPadButton>
{
	public var buttonLeft:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonUp:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonRight:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonDown:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonLeft2:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonUp2:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonRight2:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonDown2:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonA:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonB:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonC:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonD:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonE:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonF:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonG:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonH:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonI:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonJ:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonK:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonL:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonM:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonN:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonO:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonP:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonQ:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonR:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonS:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonT:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonU:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonV:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonW:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonX:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonY:TouchPadButton = new TouchPadButton(0, 0);
	public var buttonZ:TouchPadButton = new TouchPadButton(0, 0);

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:String, Action:String) {
		super();

		if (DPad != "NONE") {
			if (!MobileData.dpadModes.exists(DPad))
				throw 'The touchPad dpadMode "$DPad" doesn\'t exists.';
			for (buttonData in MobileData.dpadModes.get(DPad).buttons) {
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color)));
				add(Reflect.field(this, buttonData.button));
			}
		}

		if (Action != "NONE") {
			if (!MobileData.actionModes.exists(Action))
				throw 'The touchPad actionMode "$Action" doesn\'t exists.';
			for (buttonData in MobileData.actionModes.get(Action).buttons) {
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color)));
				add(Reflect.field(this, buttonData.button));
			}
		}

		alpha = SaveData.controlsAlpha;
		scrollFactor.set();
	}

	override public function destroy() {
		super.destroy();

		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), TouchPadButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}

	private function createButton(X:Float, Y:Float, Graphic:String, ?Color:FlxColor = 0xFFFFFF):TouchPadButton {
		var button = new TouchPadButton(X, Y, Graphic.toUpperCase());
		button.color = Color;
		button.parentAlpha = this.alpha;
		return button;
	}

	override function set_alpha(Value):Float {
		forEachAlive((button:TouchPadButton) -> {
			button.parentAlpha = Value;
		});
		return super.set_alpha(Value);
	}
}

class TouchPadButton extends TouchButton
{
	public function new(X:Float = 0, Y:Float = 0, ?labelGraphic:String){
		super(X, Y);
		if(labelGraphic != null){
			label = new FlxSprite();
			loadGraphic(Paths.image('touchpad/bg', "mobile"));
			label.loadGraphic(Paths.image('touchpad/$labelGraphic', "mobile"));
			scale.set(0.243, 0.243);
			updateHitbox();
			updateLabelPosition();
			statusBrightness = [1, 0.9, 0.6];
			statusIndicatorType = BRIGHTNESS;
			indicateStatus();
			solid = false;
			immovable = true;
			moves = false;
			antialiasing = SaveData.globalAntialiasing;
			label.antialiasing = SaveData.globalAntialiasing;
			tag = labelGraphic.toUpperCase();
		}
	}
}
