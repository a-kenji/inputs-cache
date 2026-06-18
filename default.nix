{ flake-parts, ... }@inputs:
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    ./module.nix
    ./formatter.nix
    ./devshells.nix
  ];

  flake.flakeModules.default = ./module.nix;

  flake.lib = import ./lib.nix;
}
