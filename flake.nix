{
  description = "Cassotis Chinese input method for Fcitx 5";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forSystems = nixpkgs.lib.genAttrs systems;
      packageFor = pkgs: pkgs.callPackage ./packaging/nix/package.nix { };
    in {
      overlays.default = final: prev: { fcitx5-cassotis = packageFor final; };
      packages = forSystems (system: rec {
        fcitx5-cassotis = packageFor nixpkgs.legacyPackages.${system};
        default = fcitx5-cassotis;
      });
      checks = forSystems (system:
        let
          desktop = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ({ pkgs, ... }: {
              nixpkgs.overlays = [ self.overlays.default ];
              i18n.inputMethod = {
                enable = true;
                type = "fcitx5";
                fcitx5.addons = [ pkgs.fcitx5-cassotis ];
              };
              system.stateVersion = "26.05";
            }) ];
          };
        in {
          inherit (self.packages.${system}) fcitx5-cassotis;
          input = import ./packaging/nix/input-check.nix {
            pkgs = nixpkgs.legacyPackages.${system};
            cassotis = self.packages.${system}.fcitx5-cassotis;
            framework = desktop.config.i18n.inputMethod.package;
          };
        });
    };
}
