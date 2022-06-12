#ifndef ROTATION_LUTS
#define ROTATION_LUTS

#define PI 3.14159265
float SIN[360];
float COS[360];

void fill_angles()
{
    int i;

    for (i=0;i<360;i++)
    {
        SIN[i] = sinf(i * PI/180.0);
        COS[i] = cosf(i * PI/180.0);
    }
}

#endif

