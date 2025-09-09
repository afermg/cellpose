{
  lib,
  # build deps
  buildPythonPackage,
  fetchFromGitHub,
  # Py build
  setuptools-scm,
  # Deps
  torch,
  numpy,
  scipy,
  natsort,
  tqdm,
  torchvision,
  opencv-python-headless,
  fastremap,
  imagecodecs,
  tifffile,
  scikit-image,
  fill-voids,
  roifile,
  segment-anything,
  loguru,
}:
buildPythonPackage {
  pname = "cellpose";
  version = "0.4.6";

  src = ./..; # For local testing, add flag --impure when running
  # src = fetchFromGitHub {
  #   owner = "afermg";
  #   repo = "cellpose";
  #   rev = "";
  #   sha256 = "";
  # };

  pyproject = true;
  buildInputs = [
    setuptools-scm
    # setuptools
  ];
  dependencies = [
    torch
    numpy
    scipy
    natsort
    tqdm
    torchvision
    opencv-python-headless
    fastremap
    imagecodecs
    natsort
    tifffile
    scikit-image
    fill-voids
    roifile
    segment-anything
    loguru
  ];

  pythonImportsCheck = [
  ];

  meta = {
    description = "cellpose";
    homepage = "https://github.com/afermg/cellpose";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ afermg ];
    platforms = lib.platforms.all;
  };
}
