package shaders;

class InvertShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	void main()
	{
		vec4 texture = texture2D(bitmap, openfl_TextureCoordv.xy);
		float alpha = texture.a * openfl_Alphav;
		gl_FragColor = vec4((vec3(1.0) - texture.rgb) * alpha, alpha);
	}
	')

	public function new()
	{
		super();
	}
}
