# Convert Pixel data of an Image to Lua table

from PIL import Image

def rgb_to_hex(rgb: tuple):
    h = ""
    for c in rgb[:3]:
        h += hex(c)[2:].zfill(2)
    return h

def image_to_table(image_path) -> str:

    image = Image.open(image_path).convert("RGBA")
    pixels = image.load()
    table = "{\n"

    for y in range(image.height):
        row = "{ "
        for x in range(image.width):
            pixel = pixels[x, y]
            if pixel[3]:
                c = "\"" + rgb_to_hex(pixel) + "\", "
            else:
                c = "nil, "
            row += c
        row += "},\n"
        table += row

    table += "}"

    return table

def main(argv):
    if len(argv) == 1:
        print("Filename not provided")
        return
    if len(argv) == 2:
        fp = argv[1]
        if not os.path.exists(fp):
            print("File not exist")
            return
        table = image_to_table(fp)
        print(table)

if __name__ == "__main__":
    import sys
    import os
    main(sys.argv)

