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
    valgrind
    (texlive.combine{ inherit (texlive) scheme-medium; })
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

    ".config/wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/wezterm;
	  recursive = true;
    };

    ".config/waybar" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/waybar;
	  recursive = true;
    };

    ".config/wofi" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/wofi;
	  recursive = true;
    };

    ".config/ohmyposh" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/ohmyposh;
	  recursive = true;
    };

    ".zshrc" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/zshrc;
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
