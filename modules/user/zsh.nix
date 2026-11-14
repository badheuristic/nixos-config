{ config, pkgs, theme, ... }:

{
  programs.zsh = {
    enable = true;
    # enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";
    
    initContent = ''
      # NixOS Icon + Directory + Prompt Character
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#${theme.alt}"
      PROMPT="%F{#${theme.primary}} %f %F{#${theme.fg}}%~%f > "

      zle-line-init() { echo -ne "\e[2 q" }
      zle-keymap-select() { echo -ne "\e[2 q" }
      # zle -N zle-line-init
      # zle -N zle-keymap-select

      # Map Home and End keys
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      
      # Fallback sequences for alternative terminal compatability
      bindkey "^[[1~" beginning-of-line
      bindkey "^[[4~" end-of-line

      # Aliases
      alias cc='CLAUDE_CONFIG_DIR=~/.cc claude'
      alias cc-work='CLAUDE_CONFIG_DIR=~/.cc-work claude'
      alias vim='nvim'
    '';
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
