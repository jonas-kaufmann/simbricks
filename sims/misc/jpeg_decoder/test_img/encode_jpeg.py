import argparse
from pathlib import Path

from PIL import Image


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Encode all .jpg images in a folder with JPEG parameters."
    )
    parser.add_argument(
        "src_folder", type=Path, help="Source folder containing .jpg files"
    )
    parser.add_argument(
        "dest_folder", type=Path, help="Destination folder for encoded files"
    )
    parser.add_argument(
        "subsampling",
        help="JPEG subsampling mode (e.g. 4:4:4, 4:2:2)",
    )
    parser.add_argument(
        "--optimize",
        action="store_true",
        help="Enable JPEG optimize",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()

    source_folder = args.src_folder
    destination_folder = args.dest_folder

    if not source_folder.is_dir():
        raise SystemExit(
            f"Source folder does not exist or is not a directory: {source_folder}"
        )
    destination_folder.mkdir(parents=True, exist_ok=True)

    for source_path in sorted(source_folder.iterdir()):
        if source_path.suffix.lower() != ".jpg":
            continue

        with Image.open(source_path) as img:
            width, height = img.size
            destination_path = destination_folder / source_path.name
            img.save(
                destination_path,
                "JPEG",
                quality=95,
                optimize=args.optimize,
                progressive=False,
                subsampling=args.subsampling,
            )

            compressed_size = destination_path.stat().st_size
            print(
                f"Image: {source_path.name}, Dimensions : {width}x{height}, "
                f"Compressed Size: {compressed_size} bytes"
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
