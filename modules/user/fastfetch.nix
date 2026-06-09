{
  programs.fastfetch = {
    enable = true;
    settings = {
      # "$schema" removed — not needed at runtime, can cause serialization issues

      logo = {
        type = "kitty";
        source = ../../assets/nixos.png;
        width = 10;
        height = 5;
        padding = {
          top = 1;
          left = 2;
        };
      };

      display = {
        separator = "  ";
        color = {
          keys = "magenta";
        };
        size = {
          ndigits = 0;
          maxPrefix = "MB";
        };
        key = {
          type = "icon";
        };
      };

      modules = [
        "break"   # empty line before output
        {
          type = "title";
          color = {
            user = "green";
            at = "red";
            host = "blue";
          };
        }
        "os"
        "kernel"
        "memory"
        "packages"
        "uptime"
        {
          type = "colors";
          key = "Colors";
          block = {
            range = [ 1 6 ];
          };
        }
      ];
    };
  };
}
