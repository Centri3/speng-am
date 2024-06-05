#auto_version
#extension GL_EXT_texture_array: enable
#auto_defines

#include "libcst.glh"

#ifdef _FRAGMENT_

void main() {
    out_color = vec4(encode_temp(get_sun_glow_map(get_surface_point()) * sun_surf_temp));
}

#endif
