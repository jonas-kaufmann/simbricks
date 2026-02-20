#!/usr/bin/env python3
"""
Combine rolling Verilator VCD chunks like:
  verilator_trace_0.vcd, verilator_trace_1.vcd, ...

Behavior:
- Keep the full first file (including header).
- For subsequent files, strip the VCD header and keep everything starting from the
  first time marker line '#<time>' (inclusive).

Usage:
  python3 combine_vcd.py -o combined.vcd verilator_trace_0.vcd verilator_trace_1.vcd
  python3 combine_vcd.py -o combined.vcd verilator_trace_*.vcd
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import Iterable, Optional, TextIO


TIME_RE = re.compile(r"^#\d+\s*$")
ENCODING = "utf-8"


def copy_stream(src: TextIO, dst: TextIO, bufsize: int = 1024 * 1024) -> None:
    """Copy src to dst in chunks."""
    while True:
        chunk = src.read(bufsize)
        if not chunk:
            break
        dst.write(chunk)


def append_vcd_from_first_time_marker(path: str, out: TextIO) -> None:
    """
    Append VCD content from `path` into `out`, stripping header.

    Header definition:
      - Everything before the first time marker line '#<digits>'
      - The first time marker line itself IS kept (per user requirement).
    """
    found_first_time = False
    with open(path, "r", encoding=ENCODING, errors="replace", newline="") as f:
        for line in f:
            if not found_first_time:
                if TIME_RE.match(line):
                    found_first_time = True
                    out.write(line)  # keep the first time marker
                # else: still in header, drop
                continue
            out.write(line)

    if not found_first_time:
        raise ValueError(
            f"{path}: did not find any VCD time marker line like '#123'. "
            "File may be truncated or not a VCD."
        )


def main(argv: Optional[Iterable[str]] = None) -> int:
    p = argparse.ArgumentParser(description="Combine rolling Verilator VCD files.")
    p.add_argument(
        "inputs",
        nargs="+",
        help="Input .vcd files in the order they should be concatenated."
    )
    p.add_argument(
        "-o",
        "--output",
        required=True,
        help="Output .vcd path (will be overwritten). Use '-' for stdout.",
    )
    args = p.parse_args(argv)

    inputs = args.inputs
    if len(inputs) < 1:
        p.error("Provide at least one input VCD file.")

    for f in inputs:
        if not os.path.isfile(f):
            p.error(f"Input not found or not a file: {f}")

    if args.output == "-":
        out_stream: TextIO = sys.stdout
        close_out = False
    else:
        out_stream = open(
            args.output, "w", encoding=ENCODING, errors="replace", newline=""
        )
        close_out = True

    try:
        # First file verbatim
        with open(
            inputs[0], "r", encoding=ENCODING, errors="replace", newline=""
        ) as f0:
            copy_stream(f0, out_stream)

        # Subsequent files: strip header, keep from first time marker
        for path in inputs[1:]:
            append_vcd_from_first_time_marker(path, out_stream)
    finally:
        if close_out:
            out_stream.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
