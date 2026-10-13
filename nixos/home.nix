{ config, pkgs, ... }:

let 
    vis-treesitter = pkgs.callPackage ./pkgs/vis-treesitter.nix {};
in {
  home.username = "elijahh";
  home.homeDirectory = "/home/elijahh";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.packages = [
  	pkgs.git
    pkgs.eza
    pkgs.fzf
    pkgs.zsh-fzf-tab
    pkgs.zathura
    pkgs.oh-my-posh
    pkgs.zoxide
    pkgs.clang-tools
    pkgs.python3
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.pyright
    pkgs.ffmpeg
    pkgs.typescript
    pkgs.lua55Packages.luacheck

    pkgs.yazi

    pkgs.glsl_analyzer

    pkgs.superhtml
    pkgs.valgrind
    pkgs.gdb
    pkgs.hyprlock
    pkgs.steam-run
    pkgs.fastfetch
    pkgs.texliveFull
    pkgs.traceroute
    pkgs.hyprshot
    pkgs.haskellPackages.stack
    pkgs.haskellPackages.ghc
    pkgs.libgcc
    pkgs.google-chrome

    pkgs.pqiv
    pkgs.blender

    pkgs.rgp
    pkgs.cmake

    pkgs.siege
  ];

  home.activation = {
      nvim_link = ''
      cp ~/system/nixos/dotfiles/nvim ~/.config -r
      '';
  };



  home.file = {
  	".config/hypr" = {
	  source = ./dotfiles/hypr;
	};

	#".config/nvim" = {
	#	source = ./dotfiles/nvim;
	#};
    
    ".config/helix" = {
        source = ./dotfiles/helix;
    };
    
    ".tmux.conf" = {
        source = ./dotfiles/.tmux.conf;
    };

    ".config/vis/visrc.lua" = {
        source = ./dotfiles/vis/visrc.lua;
    };

    ".config/vis/utils.lua" = {
        source = ./dotfiles/vis/utils.lua;
    };

    ".config/vis/themes" = {
        source = ./dotfiles/vis/themes;
    };

    ".config/vis/plugins/vis-lspc" = {
        source = ./dotfiles/vis/plugins/vis-lspc;
    };

    #".config/vis/plugins/vis-treesitter" = {
    #    source = vis-treesitter.vis-treesitter;
    #};

	".config/wezterm" = {
		source = ./dotfiles/wezterm;
	};

	".config/alacritty" = {
		source = ./dotfiles/alacritty;
	};

	".config/waybar" = {
		source = ./dotfiles/waybar;
	};

	".config/ohmyposh" = {
		source = ./dotfiles/ohmyposh;
	};

        #".zshrc" = {
        #  source = ./dotfiles/zshrc;
        #};
  };

  xdg.configFile."vis/plugins/vis-treesitter" = {
    source = vis-treesitter.vis-treesitter;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };


  programs.git = {
  	enable = true;
  	settings = {
		user = {
			Name = "Elijah Hantman";
			Email = "elihantman@gmail.com";
		};
        core = {
            Editor = "nvim";
        };
	};
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

            eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/velvet.json)"
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
            zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
        '';
    shellAliases = {
        "ls" = "eza -A --icons -s=name --group-directories-first -1";
        "vim" = "nvim";
        "dup" = "wezterm start --cwd $PWD 2> /dev/null";
    };
  };

  programs.home-manager.enable = true;
}
