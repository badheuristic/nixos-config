{ config, pkgs, theme, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    theme = {
      indicator = {
        padding = { open = "▐"; close = "▌"; };
      };

      tabs = {
        active   = { fg = "#${theme.bg}"; bg = "#${theme.primary}"; };
        inactive = { fg = "#${theme.fg}"; bg = "#${theme.bg_alt}"; };
      };

      mgr = {
        cwd           = { fg = "#${theme.primary}"; italic = true; };
        find_keyword  = { fg = "#${theme.urgent}"; italic = true; };
        find_position = { fg = "#${theme.primary}"; bg = "reset"; italic = true; };
        marker_selected = { fg = "#${theme.primary}"; bg = "#${theme.primary}"; };
        marker_copied   = { fg = "#${theme.urgent}";  bg = "#${theme.urgent}"; };
        marker_cut      = { fg = "#${theme.urgent}";  bg = "#${theme.urgent}"; };
        border_symbol = "│";
        border_style  = { fg = "#${theme.bg_alt}"; };
      };

      mode = {
        normal_main = { fg = "#${theme.bg}"; bg = "#${theme.primary}"; bold = true; };
        normal_alt  = { fg = "#${theme.primary}"; bg = "#${theme.bg_alt}"; };
        select_main = { fg = "#${theme.bg}"; bg = "#${theme.urgent}"; bold = true; };
        select_alt  = { fg = "#${theme.urgent}"; bg = "#${theme.bg_alt}"; };
        unset_main  = { fg = "#${theme.bg}"; bg = "#${theme.alt}"; bold = true; };
        unset_alt   = { fg = "#${theme.alt}"; bg = "#${theme.bg_alt}"; };
      };

      status = {
        sep_left  = { open = " "; close = " "; };
        sep_right = { open = " "; close = " "; };
        progress_label  = { fg = "#${theme.fg}"; bold = true; };
        progress_normal = { fg = "#${theme.bg}"; bg = "#${theme.primary}"; };
        progress_error  = { fg = "#${theme.bg}"; bg = "#${theme.urgent}"; };
        perm_type  = { fg = "#${theme.primary}"; };
        perm_read  = { fg = "#${theme.fg}"; };
        perm_write = { fg = "#${theme.urgent}"; };
        perm_exec  = { fg = "#${theme.primary}"; };
        perm_sep   = { fg = "#${theme.alt}"; };
      };

      input = {
        border   = { fg = "#${theme.primary}"; };
        title    = { fg = "#${theme.primary}"; };
        value    = { fg = "#${theme.fg}"; };
        selected = { reversed = true; };
      };

      pick = {
        border   = { fg = "#${theme.primary}"; };
        active   = { fg = "#${theme.bg}"; bg = "#${theme.primary}"; };
        inactive = { fg = "#${theme.fg}"; };
      };

      filetype = {
        rules = [
          { url = "*/";                                                             fg = "#${theme.primary}"; }
          { mime = "image/*";                                                       fg = "#ba8baf"; }
          { mime = "{audio,video}/*";                                               fg = "#ba8baf"; }
          { mime = "application/{zip,gzip,x-tar,x-bzip2,x-7z-compressed,x-rar}";  fg = "#${theme.urgent}"; }
          { url = "*"; is = "exec";                                                 fg = "#f7ca88"; }
          { url = "*"; is = "link";                                                 fg = "#86c1b9"; }
          { url = "*"; is = "orphan";                                               fg = "#${theme.urgent}"; }
          { url = "*";                                                               fg = "#${theme.fg}"; }
        ];
      };

      icon = {
        dirs = [
          { name = ".git";      text = ""; fg = "#${theme.urgent}"; }
          { name = "Downloads"; text = ""; fg = "#dc9656"; }
          { name = "Documents"; text = ""; fg = "#dc9656"; }
          { name = "Desktop";   text = ""; fg = "#${theme.primary}"; }
          { name = "Music";     text = ""; fg = "#ba8baf"; }
          { name = "Pictures";  text = ""; fg = "#ba8baf"; }
          { name = "Videos";    text = ""; fg = "#ba8baf"; }
        ];

        files = [
          { name = "Makefile"; text = ""; fg = "#f7ca88"; }
        ];

        exts = [
          # Nix
          { name = "nix"; text = ""; fg = "#${theme.primary}"; }

          # Config
          { name = "toml"; text = ""; fg = "#86c1b9"; }
          { name = "yaml"; text = ""; fg = "#86c1b9"; }
          { name = "yml";  text = ""; fg = "#86c1b9"; }
          { name = "json"; text = ""; fg = "#86c1b9"; }

          # Shell
          { name = "sh";   text = ""; fg = "#f7ca88"; }
          { name = "zsh";  text = ""; fg = "#f7ca88"; }

          # Web
          { name = "html"; text = ""; fg = "#f7ca88"; }
          { name = "css";  text = ""; fg = "#ba8baf"; }
          { name = "js";   text = ""; fg = "#f7ca88"; }
          { name = "ts";   text = ""; fg = "#${theme.primary}"; }

          # Systems
          { name = "rs"; text = ""; fg = "#dc9656"; }
          { name = "c";  text = ""; fg = "#${theme.primary}"; }
          { name = "cpp";text = ""; fg = "#${theme.primary}"; }
          { name = "go"; text = ""; fg = "#${theme.primary}"; }

          # Scripting
          { name = "py"; text = ""; fg = "#a1b56c"; }
          { name = "lua";text = ""; fg = "#a1b56c"; }
          { name = "rb"; text = ""; fg = "#${theme.urgent}"; }

          # Archives
          { name = "zip"; text = ""; fg = "#${theme.urgent}"; }
          { name = "tar"; text = ""; fg = "#${theme.urgent}"; }
          { name = "gz";  text = ""; fg = "#${theme.urgent}"; }

          # Images
          { name = "png"; text = ""; fg = "#ba8baf"; }
          { name = "jpg"; text = ""; fg = "#ba8baf"; }

          # Media
          { name = "mp4"; text = ""; fg = "#ba8baf"; }
          { name = "mp3"; text = ""; fg = "#ba8baf"; }

          # Docs
          { name = "pdf"; text = ""; fg = "#dc9656"; }
          { name = "md";  text = ""; fg = "#${theme.fg}"; }
          { name = "txt"; text = ""; fg = "#${theme.fg}"; }
        ];

        conds = [
          { "if" = "dir";    text = ""; fg = "#${theme.primary}"; }
          { "if" = "link";   text = ""; fg = "#86c1b9"; }
          { "if" = "orphan"; text = ""; fg = "#${theme.urgent}"; }
          { "if" = "exec";   text = ""; fg = "#f7ca88"; }
          { "if" = "!dir";   text = ""; fg = "#${theme.fg}"; }
        ];
      };
    };
  };
}
