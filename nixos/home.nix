{ config, pkgs, ... }:

{
  home.username = "elijahh";
  home.homeDirectory = "/home/elijahh";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
  	git
    eza
    fzf
    zathura
    oh-my-posh
    zoxide
    clang-tools
    lua-language-server
    nixd
    valgrind
    (texlive.combine{ inherit (texlive) scheme-medium; })
  ];

  home.file = {
  	".config/hypr" = {
	  source = ./dotfiles/hypr;
	  recursive = true;
	};

  	".config/nvim" = {
	  source = ./dotfiles/nvim;
	  recursive = true;
	};

    ".config/wezterm" = {
      source = ./dotfiles/wezterm;
	  recursive = true;
    };

    ".config/waybar" = {
      source = ./dotfiles/waybar;
    };

    ".config/wofi" = {
      source = ./dotfiles/wofi;
	  recursive = true;
    };

    ".config/ohmyposh" = {
      source = ./dotfiles/ohmyposh;
	  recursive = true;
    };

    ".zshrc" = {
      source = ./dotfiles/zshrc;
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
        core = {
            Editor = "nvim";
        };
	};
  };

  programs.home-manager.enable = true;
}
