{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@attrs:
    {
      nixosConfigurations.server = nixpkgs.lib.nixosSystem rec {
        pkgs = import nixpkgs { inherit system; };
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./configuration.nix
          (
            {
              config,
              pkgs,
              options,
              ...
            }:
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          )
        ];
      };
    };
}
