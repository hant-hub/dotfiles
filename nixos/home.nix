{ config, pkgs, ... }:

{
  home.username = "elijahh";
  home.homeDirectory = "/home/elijahh";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
  	git
    eza
    zoxide
  ];

  home.file = {
  	".config/hypr" = {
	  source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/hypr;
	  recursive = true;
	};
  	".config/nvim" = {
	  source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/nvim;
	  recursive = true;
	};

    ".config/kitty" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/kitty;
    };

    ".config/waybar" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/waybar;
    };

    ".config/wofi" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/wofi;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.git = {
  	enable = true;
  	extraConfig = {
		user = {
			Name = "Elijah Hantman";
			Email = "elihantman@gmail.com";
		};
	};
  };

  programs.home-manager.enable = true;
}
