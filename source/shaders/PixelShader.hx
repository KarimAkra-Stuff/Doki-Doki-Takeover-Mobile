package shaders;

import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class PixelShader extends FlxShader // https://www.shadertoy.com/view/4l2fDz
{
  public var upFloat:Float = 0.0;
  @:glFragmentSource('
    #pragma header
    uniform float iTime;
    uniform float strength;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    void mainImage()
    {
        vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
        vec2 iResolution = openfl_TextureSize;

        float pixelFactor = (cos(strength) + 1.0) * 0.5;
        vec2 pixel_count = max(floor(iResolution * pixelFactor), 1.0);
        vec2 pixel_size = iResolution / pixel_count;
        vec2 pixel = floor(fragCoord / pixel_size) * pixel_size + 0.5 * pixel_size;
        vec2 uv = pixel / iResolution;

        fragColor = vec4(texture(iChannel0, uv).rgb, 1.0);
    }
    ')
  public function new()
  {
		data.strength.value = upFloat;//Max is 2.7
    super();
  }
}//haMBURGERCHEESBEUBRGER!!!!!!!!
