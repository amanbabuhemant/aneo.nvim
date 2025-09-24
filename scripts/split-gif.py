from PIL import Image
import os
from sys import argv

def split_gif_to_pngs(gif_path, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    with Image.open(gif_path) as im:
        for frame in range(im.n_frames):
            im.seek(frame)
            frame_path = os.path.join(output_dir, f"frame_{frame:03}.png")
            im.save(frame_path, format="PNG")

def calculate_frame_delays(gif_path, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    delays = []
    with Image.open(gif_path) as im:
        for frame in range(im.n_frames):
            im.seek(frame)
            delays.append(im.info.get("duration", 1) / 1000)
    with open(os.path.join(output_dir, "delays.txt"), 'w') as f:
        for d in delays:
            f.write(str(d))
            f.write("\n")
    print(delays)

def main(argv):
    if len(argv) != 3:
        print("usages:")
        print("\t", argv[0], "path/to/gif.gif", "output_directory")
        exit(1)
    try:
        split_gif_to_pngs(argv[1], argv[2])
        calculate_frame_delays(argv[1], argv[2])
    except Exception as e:
        print(e)

if __name__ == "__main__":
    main(argv)
