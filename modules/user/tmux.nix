{ config, pkgs, theme, ... }:

{
  programs.tmux = {
    enable = true;
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
      
      # Left: Session name (Block)
      set -g status-left " #S "
      set -g status-left-style "bg=#${theme.primary},fg=#${theme.bg},bold"
      
      # Right: Time (Block)
      set -g status-right " %H:%M "
      set -g status-right-style "bg=#${theme.primary},fg=#${theme.bg},bold"
      
      # Window Tabs (Flat)
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-current-style "bg=#${theme.alt},fg=#${theme.fg},bold"
    '';
  };
}
