package mobile;

import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import flixel.input.touch.FlxTouch;
import flixel.ui.FlxButton as UIButton;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import shaders.ColorMaskShader;

class TouchPadMappingState extends MusicBeatState
{
	var control:TouchPad;
	var positionText:FlxText;
	var positionTextBg:FlxSprite;
	var bg:FlxBackdrop;
	var ui:FlxCamera;
	var buttonBinded:Bool = false;
	var bindButton:TouchButton;
	var reset:UIButton;

	var posThingy:Float = 60.0;
	
	override public function create():Void
	{
		ui = new FlxCamera();
		ui.bgColor.alpha = 0;
		FlxG.cameras.add(ui, false);

		FlxG.mouse.visible = !FlxG.onMobile;

		bg = new FlxBackdrop(Paths.image('scrollingBG'));
		bg.velocity.set(-40, -40);
		bg.antialiasing = SaveData.globalAntialiasing;
		bg.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(bg);

		positionTextBg = FlxGradient.createGradientFlxSprite(250, 150, [FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 360);
		positionTextBg.setPosition(0, FlxG.height - positionTextBg.height);
		positionTextBg.alpha = 0.8;
		add(positionTextBg);

		positionText = new FlxText(0, FlxG.height, FlxG.width / 4, '');
		positionText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		add(positionText);

		control = MobileData.getTouchPadCustomMode(new TouchPad('RIGHT_FULL', 'NONE'));
		control.cameras = [ui];
		add(control);
		updatePosText();

		var exit = new UIButton(0, posThingy - 25, "Exit & Save", () ->
		{
			MobileData.setTouchPadCustomMode(control);
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new OptionsState());
		});
		exit.color = FlxColor.LIME;
		exit.setGraphicSize(Std.int(exit.width) * 3);
		exit.updateHitbox();
		exit.x = FlxG.width - exit.width - 70;
		exit.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		exit.label.fieldWidth = exit.width;
		exit.label.x = ((exit.width - exit.label.width) / 2) + exit.x;
		exit.label.offset.y = -10; // WHY THE FUCK I CAN'T CHANGE THE LABEL Y
		add(exit);

		reset = new UIButton(exit.x, exit.height + exit.y + 20, "Reset", () ->
		{
			remove(control);
			control = flixel.util.FlxDestroyUtil.destroy(control);
			control = MobileData.getTouchPadCustomMode(new TouchPad('RIGHT_FULL', 'NONE'));
			control.cameras = [ui];
			add(control);
			
			FlxG.sound.play(Paths.sound('cancelMenu'));
		});
		reset.color = FlxColor.RED;
		reset.setGraphicSize(Std.int(reset.width) * 3);
		reset.updateHitbox();
		reset.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		reset.label.fieldWidth = reset.width;
		reset.label.x = ((reset.width - reset.label.width) / 2) + reset.x;
		reset.label.offset.y = -10;
		add(reset);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (buttonBinded)
		{
			if (TouchFunctions.touchJustReleased)
			{
				bindButton = null;
				buttonBinded = false;
			}
			else
				moveButton(TouchFunctions.touch, bindButton);
		}
		else
		{
			control.forEachAlive((button:TouchButton) ->
			{
				if (button.justPressed)
					moveButton(TouchFunctions.touch, button);
			});
		}

		super.update(elapsed);
	}

	function updatePosText()
	{
		positionText.text = 'LEFT X: ${control.buttonLeft.x} - Y: ${control.buttonLeft.y}\n';
		positionText.text += 'DOWN X: ${control.buttonDown.x} - Y: ${control.buttonDown.y}\n\n';
		positionText.text += 'UP X: ${control.buttonUp.x} - Y: ${control.buttonUp.y}\n';
		positionText.text += 'RIGHT X: ${control.buttonRight.x} - Y: ${control.buttonRight.y}';

		positionText.setPosition(0, (((positionTextBg.height - positionText.height) / 2) + positionTextBg.y));
	}

	function moveButton(touch:FlxTouch, button:TouchButton):Void
	{
		bindButton = button;
		buttonBinded = bindButton == null ? false : true;
		if (buttonBinded)
		{
			bindButton.x = touch.x - Std.int(bindButton.width / 2);
			bindButton.y = touch.y - Std.int(bindButton.height / 2);
		}
		updatePosText();
	}
}
