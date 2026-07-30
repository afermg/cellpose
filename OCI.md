# Cellpose Nahual OCI image

Build with `nix build .#oci-image`, then use `podman load < result` or
`docker load < result`. The image is `nahual/cellpose:local` and listens at
`tcp://0.0.0.0:5555`.

```console
podman run --rm --name nahual-cellpose --device nvidia.com/gpu=all \
  -p 5555:5555 -v nahual-cellpose-cache:/tmp/nahual nahual/cellpose:local
```

Use `--gpus all` with Docker. Cellpose falls back to CPU when no GPU is exposed.
Persisting `/tmp/nahual` retains downloaded model weights. Override the endpoint
with a container argument.

Full non-Nix smoke inference:

```console
pip install 'nahual==0.0.8' numpy
NAHUAL_ADDRESS=tcp://127.0.0.1:5555 python oci/smoke_test.py
```
