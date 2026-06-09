{ config, pkgs, theme, ... }:
{
  xdg.configFile."vesktop/themes/system24.theme.css".text = ''
    /**
     * @name system24
     * @description a tui-style discord theme.
     * @author refact0r
     * @version 2.0.0
     * @invite nz87hXyvcy
     * @website https://github.com/refact0r/system24
     * @source https://github.com/refact0r/system24/blob/master/theme/system24.theme.css
     * @authorId 508863359777505290
     * @authorLink https://www.refact0r.dev
    */

    /* import theme modules */
    @import url('https://refact0r.github.io/system24/build/system24.css');

    body {
        /* font, change to "" for default discord font */
        --font: 'DejaVu Sans'; 
        --code-font: 'DejaVuSansMono Nerd Font'; 
        font-weight: 300; 
        letter-spacing: -0.05ch; 

        /* sizes */
        --gap: 12px; 
        --divider-thickness: 4px; 
        --border-thickness: 2px; 
        --border-hover-transition: 0.2s ease; 

        /* animation/transition options */
        --animations: on; 
        --list-item-transition: 0.2s ease; 
        --dms-icon-svg-transition: 0.4s ease; 

        /* top bar options */
        --top-bar-height: var(--gap); 
        --top-bar-button-position: titlebar; 
        --top-bar-title-position: off; 
        --subtle-top-bar-title: off; 

        /* window controls */
        --custom-window-controls: off; 
        --window-control-size: 14px; 

        /* dms button options */
        --custom-dms-icon: off; 
        --dms-icon-svg-url: url(""); 
        --dms-icon-svg-size: 90%; 
        --dms-icon-color-before: var(--icon-subtle); 
        --dms-icon-color-after: var(--white); 
        --custom-dms-background: off; 
        --dms-background-image-url: url(""); 
        --dms-background-image-size: cover; 
        --dms-background-color: linear-gradient(70deg, var(--blue-2), var(--purple-2), var(--red-2)); 

        /* background image options */
        --background-image: off; 
        --background-image-url: url(""); 

        /* transparency/blur options */
        --transparency-tweaks: off; 
        --remove-bg-layer: off; 
        --panel-blur: off; 
        --blur-amount: 12px; 
        --bg-floating: var(--bg-3); 

        /* other options */
        --small-user-panel: on; 

        /* unrounding options */
        --unrounding: on; 

        /* styling options */
        --custom-spotify-bar: on; 
        --ascii-titles: on; 
        --ascii-loader: system24; 

        /* panel labels */
        --panel-labels: on; 
        --label-color: var(--text-muted); 
        --label-font-weight: 500; 
    }

    /* color options */
    :root {
        --colors: on; 

        /* text colors */
        --text-0: #${theme.bg}; 
        --text-1: #${theme.fg}; 
        --text-2: #${theme.fg}; 
        --text-3: #${theme.primary}; 
        --text-4: #${theme.alt}; 
        --text-5: #${theme.urgent}; 

        /* background and dark colors */
        --bg-1: #${theme.alt}; 
        --bg-2: #${theme.bg_alt}; 
        --bg-3: #${theme.bg_alt}; 
        --bg-4: #${theme.bg}; 
        --hover: #${theme.alt}40; 
        --active: #${theme.alt}80; 
        --active-2: #${theme.alt}A0; 
        --message-hover: var(--hover); 

        /* accent colors */
        --accent-1: #${theme.primary}; 
        --accent-2: #${theme.primary}; 
        --accent-3: #${theme.primary}; 
        --accent-4: #${theme.fg}; 
        --accent-5: #${theme.fg}; 
        --accent-new: #${theme.urgent}; 
        --mention: linear-gradient(to right, #${theme.primary}40 40%, transparent); 
        --mention-hover: linear-gradient(to right, #${theme.primary}60 40%, transparent); 
        --reply: linear-gradient(to right, #${theme.alt}40 40%, transparent); 
        --reply-hover: linear-gradient(to right, #${theme.alt}60 40%, transparent); 

        /* status indicator colors */
        --online: #${theme.primary}; 
        --dnd: #${theme.urgent}; 
        --idle: #${theme.alt}; 
        --streaming: #${theme.primary}; 
        --offline: #${theme.bg_alt}; 

        /* border colors */
        --border-light: var(--hover); 
        --border: var(--active); 
        --border-hover: var(--accent-2); 
        --button-border: hsl(220, 0%, 100%, 0.1); 

        /* base colors */
        --red-1: #${theme.urgent};
        --red-2: #${theme.urgent};
        --red-3: #${theme.urgent};
        --red-4: #${theme.urgent};
        --red-5: #${theme.urgent};

        --green-1: #${theme.primary};
        --green-2: #${theme.primary};
        --green-3: #${theme.primary};
        --green-4: #${theme.primary};
        --green-5: #${theme.primary};

        --blue-1: #${theme.primary};
        --blue-2: #${theme.primary};
        --blue-3: #${theme.primary};
        --blue-4: #${theme.primary};
        --blue-5: #${theme.primary};

        --yellow-1: #${theme.alt};
        --yellow-2: #${theme.alt};
        --yellow-3: #${theme.alt};
        --yellow-4: #${theme.alt};
        --yellow-5: #${theme.alt};

        --purple-1: #${theme.primary};
        --purple-2: #${theme.primary};
        --purple-3: #${theme.primary};
        --purple-4: #${theme.primary};
        --purple-5: #${theme.primary};
    }
  '';
}
