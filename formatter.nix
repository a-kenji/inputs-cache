{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
      programs.deadnix.enable = true;
      programs.flake-edit.enable = true;
      programs.nixf-diagnose.enable = true;
      programs.sizelint.enable = true;
      programs.shellcheck.enable = true;
      programs.typos.enable = true;
    };
  };
}
