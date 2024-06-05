#auto_version
#extension GL_EXT_texture_array: enable
#auto_defines

#include "libcst.glh"

#ifdef _FRAGMENT_

void main() {
    out_color = vec4(get_main_sequence_height_map(get_surface_point()));
}

#endif
