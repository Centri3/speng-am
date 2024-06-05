#auto_version
#extension GL_EXT_texture_array: enable
#auto_defines

#include "libcst.glh"

#ifdef _FRAGMENT_

void main()
{
    float height = GetSurfaceHeight();
    out_color.rgb = GetGasGiantCloudsColor(height).rgb;

    //float a = cloudsLayer - height;
    //OutColor.a = exp(-55.0 * a * a) * cloudsCoverage;
    out_color.a = 1.0 * dot(out_color.rgb, vec3(0.299, 0.587, 0.114));

    out_color.rgb = pow(out_color.rgb, color_gamma);
    //OutColor2 = vec4(0.0);
}

#endif
