"""Request/Reply is used for synchronous communications where each question is responded with a single answer,
for example remote procedure calls (RPCs).
Like Pipeline, it also can perform load-balancing.
This is the only reliable messaging pattern in the suite, as it automatically will retry if a request is not matched with a response.

"""

import sys
from functools import partial

import numpy
import pynng
import torch
import trio
from nahual.server import responder
from skimage.segmentation import relabel_sequential

from cellpose.models import CellposeModel

# address = "ipc:///tmp/cellpose.ipc"
address = sys.argv[1]


def setup(**kwargs) -> dict:
    # Some default values
    device_id = kwargs.get("device", 0)

    setup_defaults = dict(
        device=torch.device(device_id),
        gpu="True",
    )
    execution_defaults = dict(
        return_2d=True,
        z_axis=0,
        stitch_threshold=0.1,
    )

    setup_kwargs = kwargs.get("setup_kwargs", {})
    execution_kwargs = kwargs.get("setup_kwargs", {})

    # Fill kwargs with default
    for k, v in setup_defaults.items():
        setup_defaults[k] = setup_kwargs.pop(kwargs, v)

    for k, v in execution_defaults.items():
        execution_defaults[k] = execution_kwargs.pop(kwargs, v)

    # Define parameters by combining defaults and non-defaults
    setup_params = {**setup_defaults, **setup_kwargs}
    execution_params = {**execution_defaults, **execution_kwargs}

    # Load model instance
    model = CellposeModel(
        **setup_defaults,
    )

    # Generate a json-encodable dictionary to send back to the client
    serializable_params = {
        name: {k: str(v) for k, v in d.items()}
        for name, d in zip(("setup", "execution"), (setup_params, execution_params))
    }

    # "Freeze" model in-place
    processor = partial(process_pixels, model=model, **execution_params)
    return processor, serializable_params


async def main():
    """Main function for the asynchronous server.

    This function sets up a nng connection using pynng and starts a nursery to handle
    incoming requests asynchronously.

    Parameters
    ----------
    address : str
        The network address to listen on.

    Returns
    -------
    None
    """

    with pynng.Rep0(listen=address, recv_timeout=300) as sock:
        print(f"Cellpose server listening on {address}")
        async with trio.open_nursery() as nursery:
            responder_curried = partial(responder, setup=setup)
            nursery.start_soon(responder_curried, sock)


def process_pixels(
    pixels: numpy.ndarray, model: CellposeModel, return_2d: bool = True, **kwargs
) -> list[numpy.ndarray]:
    """Load a Cellpose model"""
    result = model.eval(
        pixels,
        **kwargs,
    )
    labels = result[0]
    if return_2d:
        if labels.ndim == 3:  # Cellpose squeezes dims!
            labels = labels.max(axis=0)

            # Cover case where the reduction on z removes an entire item
            labels = relabel_sequential(labels)[0]

            # HACK: Add tile/batch dimension
            labels = labels[numpy.newaxis]

    return labels


if __name__ == "__main__":
    try:
        trio.run(main)
    except KeyboardInterrupt:
        # that's the way the program *should* end
        pass
