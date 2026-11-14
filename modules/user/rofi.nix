{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi
  ];

  # Rofi configuration from https://github.com/vimichael/arch-i3-cfg/blob/main/rofi/config.rasi
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      font: "Iosevka Term 14";
      location: 1;        /* top-left anchor; combined with width=100% gives a full bar */
      xoffset: 0;
      yoffset: 0;
      fixed-num-lines: true;
      lines: 10;
      timeout {
          action: "kb-cancel";
          delay:  0;
      }
      filebrowser {
          directories-first: true;
          sorting-method:    "name";
      }
    }

    * {
        foreground:                  #c1c1c1;
        background:                  #202020;
        border-color:                #444444;
        separatorcolor:              #444444;

        normal-foreground:           #c1c1c1;
        normal-background:           #202020;

        active-foreground:           #9b8d7f;
        active-background:           #202020;

        urgent-foreground:           #5f8787;
        urgent-background:           #202020;

        selected-normal-foreground:  #202020;
        selected-normal-background:  #9b8d7f;

        selected-active-foreground:  #202020;
        selected-active-background:  #9b8d7f;

        selected-urgent-foreground:  #202020;
        selected-urgent-background:  #5f8787;

        alternate-normal-foreground: #c1c1c1;
        alternate-normal-background: #121212;

        alternate-active-foreground: #9b8d7f;
        alternate-active-background: #202020;

        alternate-urgent-foreground: #5f8787;
        alternate-urgent-background: #121212;

        spacing: 0;
    }

    window {
        background-color: #202020;
        border:           0;
        padding:          0;
        width:            100%;
        x-offset:         0;
        y-offset:         0;
    }

    mainbox {
        border:  0;
        padding: 2px 6px;
    }

    message {
        border:  0;
        padding: 1px;
    }

    textbox {
        text-color: #c1c1c1;
    }

    listview {
        fixed-height: 0;
        border:       0;
        spacing:      4px;
        scrollbar:    false;
        padding:      0;
        layout:       horizontal;
    }

    element {
        border:  0;
        padding: 0 6px;
    }

    element normal.normal {
        background-color: #202020;
        text-color:       #9b8d7f;
    }

    element normal.urgent {
        background-color: #202020;
        text-color:       #5f8787;
    }

    element normal.active {
        background-color: #202020;
        text-color:       #9b8d7f;
    }

    element selected.normal {
        background-color: #9b8d7f;
        text-color:       #202020;
    }

    element selected.urgent {
        background-color: #5f8787;
        text-color:       #202020;
    }

    element selected.active {
        background-color: #9b8d7f;
        text-color:       #202020;
    }

    element-text {
        highlight: none;
    }

    inputbar {
        spacing:  0;
        padding:  2px 4px;
        children: [ prompt, textbox-prompt-colon, entry ];
    }

    prompt {
        spacing:    0;
        text-color: #c1c1c1;
    }

    textbox-prompt-colon {
        expand:     false;
        str:        ":";
        margin:     0 0.4em 0 0;
        text-color: #9b8d7f;
    }

    entry {
        spacing:    0;
        text-color: #c1c1c1;
        cursor-width: 1ch;
    }

    scrollbar {
        width:        0;
        border:       0;
        handle-width: 0;
        padding:      0;
    }
  '';
}
