{ config, pkgs, ... }:

{
  home.username = "elijahh";
  home.homeDirectory = "/home/elijahh";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
  	git
    eza
    fzf
    zsh-fzf-tab
    zathura
    oh-my-posh
    zoxide
    clang-tools
    lua-language-server
    nixd
    valgrind
    texlive.combined.scheme-full
  ];

  home.file = {
  	".config/hypr" = {
	  source = ./dotfiles/hypr;
	};

  	".config/nvim" = {
	  source = ./dotfiles/nvim;
	};

    ".config/wezterm" = {
      source = ./dotfiles/wezterm;
    };

    ".config/waybar" = {
      source = ./dotfiles/waybar;
    };

    ".config/wofi" = {
      source = ./dotfiles/wofi;
    };

    ".config/ohmyposh" = {
      source = ./dotfiles/ohmyposh;
    };

        #".zshrc" = {
        #  source = ./dotfiles/zshrc;
        #};
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


  programs.oh-my-posh = {
        enable = true;
  };

  programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [
            "--cmd cd"
        ];
  };

  programs.fzf = {
        enable = true;
        enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
            share = true;
            saveNoDups = true;
            append = true;
    };
    initContent = ''
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            zstyle ':completion:*' list-colors '${"\${(s.:.)LS_COLORS}"}'
            zstyle ':completion:*' menu no

            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
            zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
        '';
    shellAliases = {
        "ls" = "eza -A --icons -s=name --group-directories-first -1";
        "vim" = "nvim";
        "dup" = "hyprctl dispatch exec -- wezterm start --cwd $PWD";
    };
  };

  programs.home-manager.enable = true;
}
