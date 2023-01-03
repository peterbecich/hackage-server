{
  # This is a template created by `hix init`
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
      flake-utils.lib.eachSystem supportedSystems (system:
      let
        overlays = [ haskellNix.overlay
                     (final: prev: {
                       hixProject =
                         final.haskell-nix.hix.project {
                           src = ./.;
                           evalSystem = "x86_64-linux";
                           projectFileName = "cabal.project";
                           # modules = [
                           #   { reinstallableLibGhc = true; }
                           # ];
                         };
                     })
                   ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.hixProject.flake {};
      in flake // {
        legacyPackages = pkgs;

        devShells.default = pkgs.hixProject.shellFor {
          tools = {
            cabal = "latest";
          };
          # buildInputs =
          #   with pkgs;
          #   [ haskellPackages.alex
          #   ];
        };
      });

  nixConfig = {
    extra-substituters = ["https://hackage-server.cachix.org/" "https://cache.iog.io"];
    extra-trusted-public-keys = [
      "hackage-server.cachix.org-1:iw0iRh6+gsFIrxROFaAt5gKNgIHejKjIfyRdbpPYevY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
