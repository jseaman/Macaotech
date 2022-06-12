#ifndef VECTOR_H
#define VECTOR_H

#include "rotation.h"

typedef struct {
    float x;
    float y;
} vec2_t;

typedef struct {
    float x;
    float y;
    float z;
} vec3_t;

vec3_t vec3_rotate_x(vec3_t v, int angle)
{
    vec3_t rotated_vector = {
        v.x,
        v.y * COS[angle] - v.z * SIN[angle],
        v.y * SIN[angle] + v.z * COS[angle]
    };
    
    return rotated_vector;
}

vec3_t vec3_rotate_y(vec3_t v, int angle)
{
    vec3_t rotated_vector = {
        v.x * COS[angle] - v.z * SIN[angle],
        v.y,
        v.x * SIN[angle] + v.z * COS[angle]
    };

    return rotated_vector;
}

vec3_t vec3_rotate_z(vec3_t v, int angle)
{
    vec3_t rotated_vector = {
        v.x * COS[angle] - v.y * SIN[angle],
        v.x * SIN[angle] + v.y * COS[angle],
        v.z
    };

    return rotated_vector;
}

#endif

