{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        name = "inputs-cache";
        packages = [
          self'.formatter.outPath
        ];
      };
    };
}
