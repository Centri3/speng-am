#auto_version
#extension GL_EXT_texture_array: enable
#auto_defines

#include "libcst.glh"

#ifdef _FRAGMENT_

void main() {
    vec3 point = get_surface_point();

    float height_sun = get_sun_height_map(point);
    float height_gas = HeightMapCloudsGasGiant(point);

    // TODO
    // out_color = vec4(mix(height_sun, height_gas, sun_factor));
    out_color = vec4(height_sun);
}

#endif
