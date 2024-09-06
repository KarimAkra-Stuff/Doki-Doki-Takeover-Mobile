package mobile;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal;
import mobile.MobileButtonsList;
import mobile.TouchButton;

interface MobileControls
{
	public var buttonLeft:TouchButton;
	public var buttonUp:TouchButton;
	public var buttonRight:TouchButton;
	public var buttonDown:TouchButton;
	public var instance:FlxTypedSpriteGroup<TouchButton>;
	public var onButtonDown:FlxTypedSignal<TouchButton->Void>;
	public var onButtonUp:FlxTypedSignal<TouchButton->Void>;
	public function buttonPressed(id:MobileButtonsList):Bool;
	public function buttonJustPressed(id:MobileButtonsList):Bool;
	public function buttonJustReleased(id:MobileButtonsList):Bool;
}