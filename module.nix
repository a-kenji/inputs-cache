{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.inputs-cache;
in
{
  options.inputs-cache = {
    enable = (mkEnableOption "realizing the flake's inputs as a check") // {
      default = true;
    };

    transitive = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Also realize transitive inputs (inputs of inputs).
        When false, only the flake's direct inputs are realized.
      '';
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "nixpkgs" ];
      description = ''
        Top-level input names to skip.
        Their transitive inputs are skipped with them.
      '';
    };

    checkName = mkOption {
      type = types.str;
      default = "inputs";
      description = "Name of the generated `checks.<system>.<name>` attribute.";
    };
  };

  config.perSystem =
    { pkgs, ... }:
    {
      # Thin wrapper over `lib.nix`, so the flake-parts path and the plain module
      # depend on the same lib.
      checks = mkIf cfg.enable {
        ${cfg.checkName} = (import ./lib.nix).mkInputsCheck {
          inherit pkgs inputs;
          inherit (cfg) transitive exclude;
          name = cfg.checkName;
        };
      };
    };
}
