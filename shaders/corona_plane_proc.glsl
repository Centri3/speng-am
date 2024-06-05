#auto_version
#auto_defines

#include "libcst_shared.glh"

struct BrightTy {
    float gamma;
    float brightness;
    float ray_brightness;
    float spot_brightness;
};

struct ShapeTy {
    float ray_density;
    float ray_curvature;
    float scale;
    float sin_freq;
};

struct EyeTy {
    vec3 pos;
    float anim_time;
};

#uniform_block

#ifdef _VERTEX_

layout(location = 0) in vec4 in_vert_pos;
layout(location = 1) in vec4 in_vert_tex_coord;
out vec2 out_tex_coord;
out vec3 out_pix_pos;

void main() {
    gl_Position = Mvp * in_vert_pos;
    out_tex_coord = in_vert_tex_coord.xy;
    out_pix_pos = in_vert_pos.xyz;
}

#else

in vec2 out_tex_coord;
in vec3 out_pix_pos;
layout(location = 0) out vec4 out_color;

#define in_tex_coord out_tex_coord
#define in_pix_pos out_pix_pos

void main(void)
{
    vec3 _color = Color;
    BrightTy bright = BrightTy(Bright.x, Bright.y, Bright.z, Bright.w);
    ShapeTy shape = ShapeTy(Shape.x, Shape.y, Shape.z, Shape.w);
    EyeTy eye = EyeTy(vec3(EyePos.x, EyePos.y, EyePos.z), EyePos.w);

    vec2 uv0 = in_tex_coord * 2.0 - 1.0;
    vec2 uv = uv0 * shape.ray_curvature * 0.05;
	vec2 uvn = normalize(uv);

    float r0 = sqrt(dot(uv0, uv0));
    float r = sqrt(dot(uv, uv));
    float x = dot(uvn, vec2(0.5, 0.0)) - eye.anim_time;
    float y = dot(uvn, vec2(0.0, 0.5)) - eye.anim_time;

    float rays = noise_fbm_float(
        vec3(
            (r + x) / 60.0 * shape.ray_density,
            (r + y) / 60.0 * shape.ray_density,
            0.0
        ),
        NoiseParams(2.6f, 8.0f, 0.2f, 0.0f, 0.0001, 0.1, 0.55)
    );

    rays = smoothstep(bright.gamma, bright.gamma + bright.ray_brightness, rays);
    rays = sqrt(rays);

    float eucl_dist = sqrt(pow(in_pix_pos.x, 2.0f)
        + pow(in_pix_pos.y, 2.0f)
        + pow(in_pix_pos.z, 2.0f)
    );

    vec3 color = mix(
        1.0f - vec3(rays),
        vec3(0.95f),
        bright.spot_brightness - 2000.0 * r / (shape.ray_curvature * bright.brightness)
    ) * 1.8f;
    color *= _color;
    color += vec3(0.3 * (_color.r + _color.g + _color.b));
    color *= saturate(0.74f - eucl_dist);

    uv  = uv0 * 36.0f * 0.05;
	uvn = normalize(uv);

    r0 = sqrt(dot(uv0, uv0));
    r = sqrt(dot(uv, uv));
    x = dot(uvn, vec2(0.5, 0.0)) - eye.anim_time * 3.0f;
    y = dot(uvn, vec2(0.0, 0.5)) - eye.anim_time * 3.0f;

    float surface = noise_fbm_float(
        vec3(
            (r + x) / 60.0 * shape.ray_density,
            (r + y) / 60.0 * shape.ray_density,
            0.0
        ),
        NoiseParams(4.9f, 8.0f, 0.0f, 0.0f, 0.0001, 0.13, 0.85)
    );

    surface = smoothstep(bright.gamma, bright.gamma + bright.ray_brightness, surface);
    surface = sqrt(surface);

    color += saturate(mix(
        1.0f - vec3(surface),
        vec3(1.15f),
        bright.spot_brightness - 3000.0 * r / (36.0f * bright.brightness)
    ) * 10.8f * _color);

    float prominences = noise_fbm_float(
        vec3(
            (r + x) / 60.0 * shape.ray_density,
            (r + y) / 60.0 * shape.ray_density,
            0.0
        ),
        NoiseParams(3.2f, 8.0f, 0.4f, 0.0f, 0.0001, 0.1, 0.55)
    );

    // Doing this 3 times allows prominences to be brighter near the middle. There's probably a
    // better way to do this, but I'm inexperienced.

    color += saturate(
        mix(
            1.0f - vec3(prominences),
            vec3(0.55f),
            bright.spot_brightness - 2000.0 / (36.0f * bright.brightness)
        ) * _color
    ) * 0.2f;
    color += saturate(
        mix(
            1.0f - vec3(prominences),
            vec3(0.6f),
            bright.spot_brightness - 2000.0 / (36.0f * bright.brightness)
        ) * _color
    ) * 3.0f;
    color += saturate(
        mix(
            1.0f - vec3(prominences),
            vec3(0.65f),
            bright.spot_brightness - 2000.0 / (36.0f * bright.brightness)
        ) * _color
    ) * 7.0f;

    vec3 ray = in_pix_pos + eye.pos;
    float dist = length(ray);

    float fade = clamp(dist - 0.01f, 0.0f, 1.0f)
        * clamp(1.0 - r0, 0.0, 1.0)
        * clamp(abs(ray.z / dist) - 0.1, 0.0, 1.0);

    out_color.rgb = fade * pow(max(color.rgb, 0.0), vec3(2.2f));
}

#endif
