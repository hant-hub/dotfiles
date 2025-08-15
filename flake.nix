{
  description = "System Configuration";

  inputs =  {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    hyprland.url = "github:hyprwm/hyprland?ref=v0.36.0";

    rose-pine-hyprcursor = {
        url = "github:ndom91/rose-pine-hyprcursor";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    home-manager = {
    	url = "github:nix-community/home-manager/release-25.05";
	    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:

	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
			};
		};
	in
	{
		nixosConfigurations = {
			elilaptop = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs; };
				modules = [
					./nixos/configuration.nix
				];
			};
		};

        homeConfigurations = {
			elijahh = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
				modules = [
					./nixos/home.nix
				];
			};
        };
	};

}
