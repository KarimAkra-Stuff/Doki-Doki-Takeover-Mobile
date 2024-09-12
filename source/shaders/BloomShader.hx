package shaders;

class BloomShader extends FlxShader // Taken from BBPanzu anime mod hueh
{
	@:glFragmentSource('
	#pragma header
    uniform float funrange;
    uniform float funsteps;
    uniform float funthreshhold;
    uniform float funbrightness;

	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	void mainImage() {
	vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;

    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);

    float threshholdMult = funthreshhold * 3.0;
    float stepVal = funsteps * funbrightness;

    for (float i = -funrange; i < funrange; i += funsteps) {
        float falloff = 1.0 - abs(i / funrange);

        vec2 offset1 = vec2(i, 0.0);
        vec2 offset2 = vec2(i, -i);

        vec4 blur1 = texture(iChannel0, uv + offset1);
        vec4 blur2 = texture(iChannel0, uv + offset2);

        float brightness1 = blur1.r + blur1.g + blur1.b;
        float brightness2 = blur2.r + blur2.g + blur2.b;

        if (brightness1 > threshholdMult) {
            fragColor += blur1 * falloff * stepVal;
        }
        if (brightness2 > threshholdMult) {
            fragColor += blur2 * falloff * stepVal;
        }
    }
}

	')

	public function new(range:Float = 0.1, steps:Float = 0.005, threshhold:Float = 0.8, brightness:Float = 7.0)
	{
		super();

		data.funrange.value = [range];
		data.funsteps.value = [steps];
		data.funthreshhold.value = [threshhold];
		data.funbrightness.value = [brightness];
	}
}
