{ config, pkgs, theme, ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0; # Recommended for Neovim responsiveness
    
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      # Sane window splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Status bar at the top
      set-option -g status-position top

      # Flat UI Status Bar Styling
      set -g status-style "bg=#${theme.bg_alt},fg=#${theme.fg}"
      
      # Left: Session name (Pill)
      set -g status-left "#[fg=#${theme.primary},bg=#${theme.bg_alt}]#[bg=#${theme.primary},fg=#${theme.bg},bold]#S#[fg=#${theme.primary},bg=#${theme.bg_alt}] "
      set -g status-left-length 50
      
      # Right: Time (Pill)
      set -g status-right " #[fg=#${theme.primary},bg=#${theme.bg_alt}]#[bg=#${theme.primary},fg=#${theme.bg},bold]%H:%M#[fg=#${theme.primary},bg=#${theme.bg_alt}]"
      
      # Window Tabs (Pills)
      set -g window-status-format " #[fg=#${theme.alt},bg=#${theme.bg_alt}]#[bg=#${theme.alt},fg=#${theme.fg},bold]#I:#W#[fg=#${theme.alt},bg=#${theme.bg_alt}] "
      set -g window-status-current-format " #[fg=#${theme.primary},bg=#${theme.bg_alt}]#[bg=#${theme.primary},fg=#${theme.bg},bold]#I:#W#[fg=#${theme.primary},bg=#${theme.bg_alt}] "

      # Floating Term
      bind-key -n M-i display-popup -w 80% -h 80% -E "$SHELL"

      # Mouse
      set -g mouse on

      # Vi copy mode bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    '';
  };
}
