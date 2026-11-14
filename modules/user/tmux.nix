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
      
      # Left: session name
      set -g status-left "#[bg=#${theme.primary},fg=#${theme.bg},bold] #S #[default]"
      set -g status-left-length 50
      
      # Right: clock
      set -g status-right "#[bg=#${theme.primary},fg=#${theme.bg},bold] %H:%M #[default]"
      
      # Window indicators: flat rectangle on the active window, dim number otherwise
      set -g window-status-format " #I "
      set -g window-status-current-format " #I "
      set -g window-status-style "bg=#${theme.bg_alt},fg=#${theme.alt}"
      set -g window-status-current-style "bg=#${theme.primary},fg=#${theme.bg},bold"
      set -g window-status-separator ""

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
