
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "GBADefs.h"

#include "mesh.h"

triangle_t triangles_to_render[N_MESH_FACES];

vec3_t camera_position = { 0, 0, -5 };

struct {
    int x,y,z;
} cube_rotation = { 0, 0, 0 };

int fov_factor = 128;

#define LOWRES_WIDTH 160
#define LOWRES_HEIGHT 128

unsigned short clear_buffer[LOWRES_HEIGHT*LOWRES_WIDTH];

#define BACKBUFFER 0x10
unsigned short* FrontBuffer = (unsigned short*)0x6000000;
unsigned short* BackBuffer = (unsigned short*)0x600A000;

unsigned short *videoPtr;

void draw_pixel(int, int, unsigned short);
void draw_line(int, int, int, int, unsigned short);
void update();
void render();

void flip()	
{
	if (*display_control & BACKBUFFER)
    {
		*display_control &= ~BACKBUFFER;
        videoPtr = BackBuffer;
    }
    else
    {
		*display_control |= BACKBUFFER;
        videoPtr = FrontBuffer;
    }
}


int main() {
    fill_angles();

    //memset(clear_buffer,0,LOWRES_HEIGHT*LOWRES_WIDTH*sizeof(unsigned short));

    *display_control = MODE_5 | BG2_ENABLE;

    //draw_line(0, 0, LOWRES_WIDTH, LOWRES_HEIGHT, RGB(0,31,0));
    //draw_line(LOWRES_WIDTH, 0, 0, LOWRES_HEIGHT, RGB(31,0,31));

    while (1)
    {
        wait_vblank();
        update();
        flip();
        render();
    }
}

vec2_t project(vec3_t point) {
    vec2_t projected_point = {
        (fov_factor * point.x) / point.z,
        (fov_factor * point.y) / point.z
    };
    return projected_point;
}

void update() {
    int i,j;
    face_t mesh_face;
    vec3_t face_vertices[3];
    triangle_t projected_triangle;
    vec3_t transformed_vertex;
    vec2_t projected_point;

    cube_rotation.x = (cube_rotation.x + 5) % 360;
    cube_rotation.y = (cube_rotation.y + 5) % 360;
    cube_rotation.z = (cube_rotation.z + 5) % 360;

    for (i = 0; i < N_MESH_FACES; i++)
    {
        mesh_face = mesh_faces[i];
    
        face_vertices[0] = mesh_vertices[mesh_face.a - 1];
        face_vertices[1] = mesh_vertices[mesh_face.b - 1];
        face_vertices[2] = mesh_vertices[mesh_face.c - 1];

        for (j = 0; j < 3; j++)
        {
            transformed_vertex = face_vertices[j];

            transformed_vertex = vec3_rotate_x(transformed_vertex, cube_rotation.x);
            transformed_vertex = vec3_rotate_y(transformed_vertex, cube_rotation.y);
            transformed_vertex = vec3_rotate_z(transformed_vertex, cube_rotation.z);

            // Translate the vertex away from the camera
            transformed_vertex.z -= camera_position.z;

            projected_point = project(transformed_vertex);

            // scale and translate the projected points to middle of screen
            projected_point.x += (LOWRES_WIDTH / 2);
            projected_point.y += (LOWRES_HEIGHT / 2);

            projected_triangle.points[j] = projected_point;
        }

        triangles_to_render[i] = projected_triangle;
    }
}

void draw_triangle(int x0, int y0, int x1, int y1, int x2, int y2, short color)
{
    draw_line(x0, y0, x1, y1, color);
    draw_line(x1, y1, x2, y2, color);
    draw_line(x2, y2, x0, y0, color);
}

void clear_display()
{
    //memcpy16_dma(videoPtr,clear_buffer,LOWRES_HEIGHT*LOWRES_WIDTH);
    memset(videoPtr,0,LOWRES_HEIGHT*LOWRES_WIDTH*sizeof(unsigned short));
    /*int i;

    for (i=0;i<LOWRES_HEIGHT*LOWRES_WIDTH;i++)
        videoPtr[i] = 0;*/
}

void render() {
    int i;

    clear_display();

    // Loop all projected triangles and render them
    for (i = 0; i < N_MESH_FACES; i++) {
        triangle_t triangle = triangles_to_render[i];        

        draw_triangle(
            triangle.points[0].x, triangle.points[0].y,
            triangle.points[1].x, triangle.points[1].y,
            triangle.points[2].x, triangle.points[2].y,
            RGB(0,31,0));
    }
}

/////////////////////////////////////////////////////////////
// Function: DrawPixel3
// Draws a pixel in mode 3
/////////////////////////////////////////////////////////////
void draw_pixel(int x, int y, unsigned short color)
{
	videoPtr[y * LOWRES_WIDTH + x] = color;
}

/////////////////////////////////////////////////////////////
// Function: DrawLine3
// Bresenham's infamous line algorithm
/////////////////////////////////////////////////////////////
void draw_line(int x1, int y1, int x2, int y2, unsigned short color)
{
	int i, deltax, deltay, numpixels;
	int d, dinc1, dinc2;
	int x, xinc1, xinc2;
	int y, yinc1, yinc2;

	//calculate deltaX and deltaY
	deltax = abs(x2 - x1);
	deltay = abs(y2 - y1);

	//initialize
	if(deltax >= deltay)
	{
		//If x is independent variable
		numpixels = deltax + 1;
		d = (2 * deltay) - deltax;
		dinc1 = deltay << 1;
		dinc2 = (deltay - deltax) << 1;
		xinc1 = 1;
		xinc2 = 1;
		yinc1 = 0;
		yinc2 = 1;
	}
	else
	{
		//if y is independant variable
		numpixels = deltay + 1;
		d = (2 * deltax) - deltay;
		dinc1 = deltax << 1;
		dinc2 = (deltax - deltay) << 1;
		xinc1 = 0;
		xinc2 = 1;
		yinc1 = 1;
		yinc2 = 1;
	}

	//move the right direction
	if(x1 > x2)
	{
		xinc1 = -xinc1;
		xinc2 = -xinc2;
	}
	if(y1 > y2)
	{
		yinc1 = -yinc1;
		yinc2 = -yinc2;
	}

	x = x1;
	y = y1;

	//draw the pixels
	for(i = 1; i < numpixels; i++)
	{
		draw_pixel(x, y, color);

		if(d < 0)
		{
			d = d + dinc1;
			x = x + xinc1;
			y = y + yinc1;
		}
		else
		{
			d = d + dinc2;
			x = x + xinc2;
			y = y + yinc2;
		}
	}
}




