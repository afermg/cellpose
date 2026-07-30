#!/usr/bin/env python3
"""End-to-end inference against the Cellpose OCI container."""

import json
import os

os.environ.setdefault("NAHUAL_IPC_TIMEOUT_MS", "900000")

import numpy as np
from nahual.process import dispatch_setup_process


def main() -> None:
    address = os.environ.get("NAHUAL_ADDRESS", "tcp://127.0.0.1:5555")
    setup, process = dispatch_setup_process("cellpose")
    info = setup({"device": "cpu"}, address=address)
    yy, xx = np.mgrid[:128, :128]
    image = np.exp(-((yy - 64) ** 2 + (xx - 64) ** 2) / 400).astype(np.float32)
    result = process(image[np.newaxis], address=address)
    assert result.shape[-2:] == (128, 128), result.shape
    assert np.issubdtype(result.dtype, np.integer), result.dtype
    print(
        json.dumps(
            {"setup": info, "shape": list(result.shape), "labels": int(result.max())}
        )
    )


if __name__ == "__main__":
    main()
