{
  lib,
  pkgs,
  python3Packages,
}:
let
  callPackage = lib.callPackageWith (pkgs // packages // python3Packages);
  packages = {
    cellpose = callPackage ./cellpose.nix { };
    fill-voids = callPackage ./fill_voids.nix { };
    roifile = callPackage ./roifile.nix { };
    segment-anything = callPackage ./segment_anything.nix { };
  };
in
packages
