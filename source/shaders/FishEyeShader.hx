package shaders;

import lime.utils.Assets;
import haxe.Json;

typedef FishEyeJSON =
{
	var presets:Array<Array<Float>>;
}

class FishEyeShader extends FlxShader // https://www.shadertoy.com/view/WsVSzV
{
	@:glFragmentSource('
	#pragma header
	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define iResolution openfl_TextureSize
	#define mainImage main

	uniform float warp;
	uniform float scan;

	void mainImage()
	{
		vec2 fragCoord = openfl_TextureCoordv * iResolution;
		vec2 uv = fragCoord / iResolution.xy;
		vec2 dc = (uv - 0.5) * (uv - 0.5);
		uv.x = (uv.x - 0.5) * (1.0 + dc.y * 0.7 * warp) + 0.5;
		uv.y = (uv.y - 0.5) * (1.0 + dc.x * 0.9 * warp) + 0.5;
		uv = clamp(uv, vec2(0.0), vec2(1.0));

		float scanEffect = 0.5 * scan * abs(sin(fragCoord.y));

		vec3 color = flixel_texture2D(bitmap, uv).rgb;

		fragColor = vec4(mix(color, vec3(0.0), scanEffect), 1.0);
	}
	')

	var json:FishEyeJSON = null;
	public var preset(default, set):Int = 0;

	function set_preset(value:Int):Int
	{
		var presetData:Array<Float> = json.presets[value];
		data.warp.value = [presetData[0]];
		data.scan.value = [presetData[1]];
		return value;
	}

	public function new()
	{
		super();

		var jsonTxt:String = Assets.getText(Paths.json('shader/fisheye'));
		json = cast Json.parse(jsonTxt);

		iTime.value = [0];
		this.preset = preset;
	}
}

