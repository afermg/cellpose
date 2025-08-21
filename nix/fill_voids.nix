{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cython,
  numpy,
  pbr,
  setuptools,
  fastremap,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "fill-voids";
  version = "2.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "seung-lab";
    repo = "fill_voids";
    tag = version;
    hash = "sha256-LbkA1K8znePKKX1ZPaAR/LB0s3JlPWn6vjddnGRWr3M=";
  };

  build-system = [
    cython
    numpy
    pbr
    setuptools
  ];

  dependencies = [
    numpy
    fastremap
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    # pytestCheckHook
  ];

  pythonImportsCheck = [
    "fill_voids"
  ];

  meta = {
    description = "Remap, mask, renumber, unique, and in-place transposition of 3D labeled images and point clouds";
    homepage = "https://github.com/seung-lab/fill_voids";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ afermg ];
  };
}
