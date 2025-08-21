{
  lib,
  buildPythonPackage,
  # fetchFromGitHub,
  fetchPypi,
  cython,
  numpy,
  setuptools,
  pkgs,
  jxrlib,
  lcms2,
  lerc,
  libdeflate,
  libpng,
  libtiff,
  libwebp,
  openjpeg,
  xz,
  zlib,
  zstd,
  pytest,
}:

let
  version = "2024.12.30";
in
buildPythonPackage {
  pname = "imagecodecs";
  inherit version;
  pyproject = true;

  # src = fetchFromGitHub {
  #   owner = "cgohlke";
  #   repo = "imagecodecs";
  #   tag = "v${version}";
  #   hash = "sha256-KtrQNABQOr3mNiWOfaZBcFceSCixPGV8Hte2uPKn1+k=";
  # };
  src = fetchPypi {
    pname = "imagecodecs";
    version = version;
    hash = "sha256-TIj3RXGTE8q+pt1fHmnJ+TNG3pHA8edw65afIjIkfyE=";
  };

  build-system = [
    cython
    numpy
    setuptools
  ];

  nativeBuildInputs = [
    pkgs.lz4.dev # lz4 was hidden by python3Packages.lz4
    lcms2.dev
    openjpeg.dev
  ];

  buildInputs = [
    pkgs.lz4
    jxrlib
    lcms2
    lerc
    libdeflate
    libpng
    libtiff
    libwebp
    openjpeg
    xz # liblzma
    zlib
    zstd
  ];

  propagatedBuildInputs = [
    numpy
    cython
  ];

  prePatch = ''
    substituteInPlace setup.py \
      --replace-fail "/usr/include/openjpeg" "${openjpeg.dev}/include/openjpeg" \
      --replace-fail "/usr/include/jxrlib" "${jxrlib}/include/jxrlib"
  '';

  nativeCheckInputs = [
    pytest
  ];

  pythonImportsCheck = [
    "imagecodecs"
  ];

  meta = {
    description = "Image transformation, compression, and decompression codecs";
    homepage = "https://github.com/cgohlke/imagecodecs";
    changelog = "https://github.com/cgohlke/imagecodecs/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
