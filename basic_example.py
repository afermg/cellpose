"""Minimal example to ensure that installation worked"""

import requests
import tifffile
import torch

from cellpose.models import CellposeModel

assert torch.cuda.is_available(), "CUDA is not available"

url = "https://cellpainting-gallery.s3.amazonaws.com/cpg0016-jump/source_4/images/2021_04_26_Batch1/images/BR00117035__2021-05-02T16_02_51-Measurement1/Images/r01c01f01p01-ch1sk1fk1fl1.tiff"

response = requests.get(url)
with open("file.tiff", "wb") as f:
    for chunk in response.iter_content(chunk_size=8192):
        if chunk:  # filter out keep-alive chunks
            f.write(chunk)
img = tifffile.imread("file.tiff")

model = CellposeModel(
    gpu=True,
    device=torch.device(0),
)

result = model.eval(img)
