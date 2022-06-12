import numpy as np
from PIL import Image 
from PIL import ImageChops

GBA_FULL_RES = (240,160)
GBA_LOW_RES = (160,128)

def write_palette(name, palette, transparent_color = None, num_colors=256):
    transparent_color_index = None

    palette = np.round(np.array(palette) * 31/255).astype(int)

    with open(name+"_pal.h",'w') as f:
        f.write("const unsigned short "+name+"_Palette["+str(num_colors)+"] = {\n")

        for i in range(0,len(palette),3):
            red = palette[i]
            green = palette[i+1]
            blue = palette[i+2]

            curr_color = (red,green,blue)

            blue<<=10
            green<<=5

            gba_pal = blue | green | red 

            if transparent_color_index == None and curr_color == transparent_color:
                transparent_color_index = int(i/3)
            
            f.write(hex(gba_pal)+",")

        f.write("\n};\n\n")

    return transparent_color_index

####################################################
#  Transform images to mode 3 or mode 5
####################################################
def img2gba_mode3_5(img_name, resolution, name):
    img = Image.open(img_name).resize(resolution)

    red = np.round(np.array(img.getdata(0)) * 31/255).astype(int)
    green = np.round(np.array(img.getdata(1)) * 31/255).astype(int)
    blue = np.round(np.array(img.getdata(2)) * 31/255).astype(int)

    blue<<=10
    green<<=5

    img_ret = blue | green | red 

    with open(name+".h",'w') as f:
        f.write("const unsigned short "+name+"["+str(resolution[0]*resolution[1])+"] = {\n")

        for pixel in img_ret:
            f.write(hex(pixel)+",")

        f.write("\n};\n\n")

    return img_ret

####################################################
#  Transform images to mode 4
####################################################
def img2gba_mode4(img_name, resolution, name, pal_offset=0, num_colors=256):
    img = Image.open(img_name).resize(resolution).convert("P", palette=Image.ADAPTIVE, colors=num_colors)
    rgb = np.array([color for (color,index) in img.getcolors(num_colors)])

    write_palette(name, img.getpalette(), num_colors=num_colors)

    with open(name+"_bmp.h",'w') as f:
        f.write("const unsigned char "+name+"_Bitmap["+str(resolution[0]*resolution[1])+"] = {\n")

        for pal_ind in img.getdata():
            f.write(str(pal_ind + pal_offset)+",")

        f.write("\n};\n\n")

    return img.getdata()

####################################################
#  Break up image into tiles, palette and map
####################################################
def split_image_into_tiles_and_map(img_name, name, tile_type, pal_offset=0, gather_tiles = True, resolution = None, transparent_color = None):
    img = Image.open(img_name)

    if resolution != None:
        img = img.resize(resolution)
    
    img = img.convert("P", palette=Image.ADAPTIVE, colors=256)

    tiles = []
    tile_map = np.zeros((int(img.size[0]/8),int(img.size[1]/8))).astype(int)

    for row in range (0,img.size[1],8):
        for col in range(0,img.size[0],8):
            slice = img.crop((col,row,col+8,row+8))

            found = False
            tile_index = 0

            if gather_tiles:
                for i in range(0,len(tiles)):
                    tile = tiles[i]
                    if not ImageChops.difference(slice,tile).getbbox():
                        found = True
                        tile_index = i 
                        break

            if not found:
                tiles.append(slice)
                tile_index = len(tiles)-1
                
            tile_map[int(col/8), int(row/8)] = tile_index

    transparent_color_index = write_palette(name, img.getpalette(), transparent_color)

    with open(name+"_tiles.h",'w') as f:
        f.write("const unsigned char "+name+"_tiles["+str(len(tiles)*64)+"] = {\n")

        for tile in tiles:
            for y in range(0,8):
                for x in range(0,8):
                    pixel = tile.getpixel((x,y))

                    if pixel == transparent_color_index:
                        pixel = 0
                    else:
                        pixel += pal_offset

                    f.write(str(pixel) + ", ")

            f.write("\n")

        f.write("\n};\n")

    with open(name+"_tile_map.h",'w') as f:
        f.write("const unsigned "+tile_type+" "+name+"_tile_map["+str(tile_map.shape[0] * tile_map.shape[1])+"] = {\n")

        for row in range(0,tile_map.shape[1]):
            for col in range(0,tile_map.shape[0]):
                f.write(hex(tile_map[col,row])+", ")

            f.write("\n")

        f.write("\n};\n")
                    
    return (tiles, tile_map)

def change_color(img, original_col, new_col):
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            pixel = img.getpixel((x,y))

            if pixel==original_col:
                pixel = new_col
                img.putpixel((x,y), new_col)

    return img


