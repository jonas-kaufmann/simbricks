import sys
from PIL import Image
import os


if len(sys.argv) != 5:
    print('Usage: encode_jpeg_444_opt src_folder dest_folder subsampling optmize')
    sys.exit(1)

source_folder = sys.argv[1]
destination_folder = sys.argv[2]

for file_name in os.listdir(source_folder):
    if file_name.endswith('.jpg'):
        with Image.open(os.path.join(source_folder, file_name)) as img:
            # Getting image dimensions
            width, height = img.size
            dimension_product = width * height
            # Saving the image with specified parameters
            destination_path = os.path.join(destination_folder, file_name)
            img.save(destination_path, 'JPEG', quality=90, optimize=bool(sys.argv[4]), progressive=False, subsampling=sys.argv[3])

            # Getting the size of the compressed image
            compressed_size = os.path.getsize(destination_path)

            # Printing the dimension product and the size of the compressed image
            print(f'Image: {file_name}, Dimension Product: {dimension_product}, Compressed Size: {compressed_size} bytes')
