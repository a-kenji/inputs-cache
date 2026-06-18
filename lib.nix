{
  mkInputsCheck =
    {
      pkgs,
      inputs,
      transitive ? true,
      exclude ? [ ],
      name ? "inputs",
    }:
    let
      entriesOf =
        attrs:
        map (name: {
          inherit name;
          value = attrs.${name};
        }) (builtins.attrNames attrs);

      mkNode = entry: {
        key = entry.value.outPath;
        inherit (entry) name;
        inherit (entry.value) outPath;
        value = entry.value;
      };

      # Deduplicated transitive closure of `topInputs` store paths.
      closureOf =
        topInputs:
        builtins.genericClosure {
          startSet = map mkNode (entriesOf topInputs);
          operator = node: if node.value ? inputs then map mkNode (entriesOf node.value.inputs) else [ ];
        };

      flatOf = topInputs: map mkNode (entriesOf topInputs);

      # Strip `self` and any excluded inputs
      topInputs = removeAttrs inputs ([ "self" ] ++ exclude);
      nodes = if transitive then closureOf topInputs else flatOf topInputs;
    in
    # Suffix each name with its store hash, to keep it unique: `nixpkgs-3a2vdn5i`
    pkgs.linkFarm name (
      map (node: {
        name = "${node.name}-${
          builtins.substring 0 8 (builtins.unsafeDiscardStringContext (baseNameOf node.outPath))
        }";
        path = node.outPath;
      }) nodes
    );
}
