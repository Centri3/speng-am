#auto_version
#extension GL_EXT_texture_array: enable
#auto_defines

#include "libcst.glh"

#ifdef _FRAGMENT_

void main()
{
    vec3  point = get_surface_point();
    float surfTempS = get_sun_glow_map(point); // in thousand Kelvins

    float height = GetSurfaceHeight();
    float surfTempB = mix(1.0, GetGasGiantCloudsColor(height).a, clouds_curr_layer);
    surfTempB *= (1.0 - 0.2 * height);

    float surfTemp = mix(surfTempS, surfTempB, sun_factor) * sun_surf_temp; // in thousand Kelvins

    surfTemp = encode_temp(surfTemp); // encode to [0...1] range
	out_color = vec4(surfTemp);
}

#endif
