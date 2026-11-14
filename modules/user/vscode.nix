{ pkgs, lib, theme, ... }:

# VS Code: a "Closs" colour theme generated from the palette, and a
# pared-back workbench (no minimap, breadcrumbs, command centre or borders;
# every pane shares one background so the editor reads as a single sheet).
let
  c = name: "#${theme.${name}}";
  a = name: alpha: "#${theme.${name}}${alpha}"; # with alpha, e.g. a "primary" "40"
  none = "#00000000";

  colors = {
    # base
    "foreground" = c "fg";
    "descriptionForeground" = c "fg_dim";
    "disabledForeground" = c "fg_faint";
    "errorForeground" = c "red";
    "icon.foreground" = c "fg_dim";
    "focusBorder" = none;
    "contrastBorder" = none;
    "widget.border" = c "surface2";
    "widget.shadow" = "#00000066";
    "selection.background" = a "primary" "40";
    "textLink.foreground" = c "primary";
    "textLink.activeForeground" = c "primary_hi";
    "sash.hoverBorder" = c "surface3";
    "progressBar.background" = c "primary";

    # one background everywhere, no dividers
    "editor.background" = c "bg";
    "editor.foreground" = c "fg";
    "sideBar.background" = c "bg";
    "sideBar.border" = none;
    "sideBar.foreground" = c "fg_dim";
    "sideBarTitle.foreground" = c "fg_faint";
    "sideBarSectionHeader.background" = c "bg";
    "sideBarSectionHeader.border" = none;
    "sideBarSectionHeader.foreground" = c "fg_dim";
    "activityBar.background" = c "bg";
    "activityBar.border" = none;
    "activityBar.foreground" = c "fg";
    "activityBar.inactiveForeground" = c "fg_faint";
    "activityBar.activeBorder" = none;
    "activityBarTop.foreground" = c "fg";
    "activityBarTop.inactiveForeground" = c "fg_faint";
    "activityBarTop.activeBorder" = c "primary";
    "activityBarBadge.background" = c "primary";
    "activityBarBadge.foreground" = c "on_primary";
    "titleBar.activeBackground" = c "bg";
    "titleBar.inactiveBackground" = c "bg";
    "titleBar.activeForeground" = c "fg_dim";
    "titleBar.inactiveForeground" = c "fg_faint";
    "titleBar.border" = none;
    "statusBar.background" = c "bg";
    "statusBar.foreground" = c "fg_faint";
    "statusBar.border" = none;
    "statusBar.noFolderBackground" = c "bg";
    "statusBar.debuggingBackground" = c "bg";
    "statusBar.debuggingForeground" = c "orange";
    "statusBarItem.hoverBackground" = c "surface";
    "statusBarItem.remoteBackground" = c "bg";
    "statusBarItem.remoteForeground" = c "primary";
    "panel.background" = c "bg";
    "panel.border" = c "surface";
    "panelTitle.activeForeground" = c "fg";
    "panelTitle.inactiveForeground" = c "fg_faint";
    "panelTitle.activeBorder" = c "primary";
    "editorGroup.border" = c "surface";
    "editorGroupHeader.tabsBackground" = c "bg";
    "editorGroupHeader.tabsBorder" = none;
    "editorGroupHeader.noTabsBackground" = c "bg";

    # tabs: quiet text, the active one simply brighter
    "tab.activeBackground" = c "bg";
    "tab.inactiveBackground" = c "bg";
    "tab.activeForeground" = c "fg";
    "tab.inactiveForeground" = c "fg_faint";
    "tab.border" = none;
    "tab.activeBorder" = none;
    "tab.activeBorderTop" = none;
    "tab.hoverBackground" = c "bg";
    "tab.unfocusedActiveForeground" = c "fg_dim";
    "tab.activeModifiedBorder" = c "primary";

    # editor
    "editorCursor.foreground" = c "primary";
    "editor.lineHighlightBackground" = a "surface" "80";
    "editor.lineHighlightBorder" = none;
    "editor.selectionBackground" = a "primary" "33";
    "editor.inactiveSelectionBackground" = a "primary" "1a";
    "editor.selectionHighlightBackground" = a "primary" "1a";
    "editor.wordHighlightBackground" = a "surface3" "80";
    "editor.wordHighlightStrongBackground" = a "surface3" "b0";
    "editor.findMatchBackground" = a "yellow" "55";
    "editor.findMatchHighlightBackground" = a "yellow" "26";
    "editor.findRangeHighlightBackground" = a "surface" "80";
    "editorLineNumber.foreground" = c "surface3";
    "editorLineNumber.activeForeground" = c "fg_dim";
    "editorIndentGuide.background1" = a "surface2" "80";
    "editorIndentGuide.activeBackground1" = c "surface3";
    "editorWhitespace.foreground" = c "surface2";
    "editorRuler.foreground" = c "surface";
    "editorBracketMatch.background" = a "surface3" "80";
    "editorBracketMatch.border" = none;
    "editorGutter.background" = c "bg";
    "editorGutter.addedBackground" = c "green";
    "editorGutter.modifiedBackground" = c "blue";
    "editorGutter.deletedBackground" = c "red";
    "editorOverviewRuler.border" = none;
    "editorError.foreground" = c "red";
    "editorWarning.foreground" = c "yellow";
    "editorInfo.foreground" = c "blue";
    "editorHint.foreground" = c "fg_faint";
    "editorInlayHint.background" = none;
    "editorInlayHint.foreground" = c "fg_faint";
    "editorCodeLens.foreground" = c "fg_faint";
    "editorBracketHighlight.foreground1" = c "fg_dim";
    "editorBracketHighlight.foreground2" = c "blue";
    "editorBracketHighlight.foreground3" = c "magenta";
    "editorBracketHighlight.foreground4" = c "cyan";
    "editorBracketHighlight.foreground5" = c "yellow";
    "editorBracketHighlight.foreground6" = c "orange";
    "editorStickyScroll.background" = c "bg";
    "breadcrumb.background" = c "bg";

    # floating widgets (find, suggest, hover, quick open)
    "editorWidget.background" = c "surface";
    "editorWidget.border" = c "surface2";
    "editorSuggestWidget.background" = c "surface";
    "editorSuggestWidget.border" = c "surface2";
    "editorSuggestWidget.selectedBackground" = c "surface2";
    "editorSuggestWidget.highlightForeground" = c "primary";
    "editorSuggestWidget.focusHighlightForeground" = c "primary_hi";
    "editorHoverWidget.background" = c "surface";
    "editorHoverWidget.border" = c "surface2";
    "quickInput.background" = c "surface";
    "quickInput.foreground" = c "fg";
    "quickInputTitle.background" = c "surface";
    "quickInputList.focusBackground" = c "surface2";
    "pickerGroup.border" = c "surface2";
    "pickerGroup.foreground" = c "fg_faint";
    "menu.background" = c "surface";
    "menu.foreground" = c "fg";
    "menu.selectionBackground" = c "surface2";
    "menu.separatorBackground" = c "surface2";
    "menu.border" = c "surface2";
    "notifications.background" = c "surface";
    "notifications.border" = c "surface2";
    "notificationCenterHeader.background" = c "surface";
    "notificationToast.border" = c "surface2";

    # lists & trees
    "list.activeSelectionBackground" = c "surface";
    "list.activeSelectionForeground" = c "fg";
    "list.inactiveSelectionBackground" = c "surface";
    "list.inactiveSelectionForeground" = c "fg";
    "list.hoverBackground" = a "surface" "a0";
    "list.focusOutline" = none;
    "list.focusAndSelectionOutline" = none;
    "list.inactiveFocusOutline" = none;
    "list.highlightForeground" = c "primary";
    "list.errorForeground" = c "red";
    "list.warningForeground" = c "yellow";
    "tree.indentGuidesStroke" = c "surface2";
    "tree.inactiveIndentGuidesStroke" = c "surface";
    "scrollbar.shadow" = none;
    "scrollbarSlider.background" = a "surface3" "50";
    "scrollbarSlider.hoverBackground" = a "surface3" "90";
    "scrollbarSlider.activeBackground" = c "surface3";

    # controls
    "button.background" = c "primary";
    "button.foreground" = c "on_primary";
    "button.hoverBackground" = c "primary_hi";
    "button.secondaryBackground" = c "surface2";
    "button.secondaryForeground" = c "fg";
    "button.secondaryHoverBackground" = c "surface3";
    "button.border" = none;
    "input.background" = c "surface";
    "input.border" = none;
    "input.foreground" = c "fg";
    "input.placeholderForeground" = c "fg_faint";
    "inputOption.activeBackground" = a "primary" "33";
    "inputOption.activeBorder" = none;
    "inputValidation.errorBackground" = c "surface";
    "inputValidation.errorBorder" = c "red";
    "dropdown.background" = c "surface";
    "dropdown.border" = none;
    "dropdown.listBackground" = c "surface";
    "checkbox.background" = c "surface2";
    "checkbox.border" = none;
    "badge.background" = c "surface2";
    "badge.foreground" = c "fg";
    "keybindingLabel.background" = c "surface2";
    "keybindingLabel.border" = none;
    "keybindingLabel.bottomBorder" = none;
    "keybindingLabel.foreground" = c "fg_dim";
    "settings.headerForeground" = c "fg";
    "settings.modifiedItemIndicator" = c "primary";
    "welcomePage.tileBackground" = c "surface";

    # git & diagnostics
    "gitDecoration.addedResourceForeground" = c "green";
    "gitDecoration.untrackedResourceForeground" = c "green";
    "gitDecoration.modifiedResourceForeground" = c "blue";
    "gitDecoration.deletedResourceForeground" = c "red";
    "gitDecoration.conflictingResourceForeground" = c "orange";
    "gitDecoration.ignoredResourceForeground" = c "fg_faint";
    "diffEditor.insertedTextBackground" = a "green" "1f";
    "diffEditor.removedTextBackground" = a "red" "1f";
    "diffEditor.insertedLineBackground" = a "green" "14";
    "diffEditor.removedLineBackground" = a "red" "14";
    "diffEditor.border" = c "surface";
    "minimap.background" = c "bg";

    # integrated terminal
    "terminal.background" = c "bg";
    "terminal.foreground" = c "fg";
    "terminalCursor.foreground" = c "primary";
    "terminal.selectionBackground" = a "primary" "40";
    "terminal.ansiBlack" = c "surface2";
    "terminal.ansiBrightBlack" = c "fg_faint";
    "terminal.ansiRed" = c "red";
    "terminal.ansiBrightRed" = c "red";
    "terminal.ansiGreen" = c "green";
    "terminal.ansiBrightGreen" = c "green";
    "terminal.ansiYellow" = c "yellow";
    "terminal.ansiBrightYellow" = c "yellow";
    "terminal.ansiBlue" = c "blue";
    "terminal.ansiBrightBlue" = c "blue";
    "terminal.ansiMagenta" = c "magenta";
    "terminal.ansiBrightMagenta" = c "magenta";
    "terminal.ansiCyan" = c "cyan";
    "terminal.ansiBrightCyan" = c "cyan";
    "terminal.ansiWhite" = c "fg_dim";
    "terminal.ansiBrightWhite" = c "fg";
  };

  rule = scope: fg: extra: { inherit scope; settings = { foreground = c fg; } // extra; };
  tokenColors = [
    (rule [ "comment" "punctuation.definition.comment" ] "fg_faint" { fontStyle = "italic"; })
    (rule [ "keyword" "storage.type" "storage.modifier" "keyword.control" ] "magenta" { })
    (rule [ "keyword.operator" "punctuation" "meta.brace" ] "fg_dim" { })
    (rule [ "string" "string.quoted" "markup.inline.raw" ] "green" { })
    (rule [ "constant.character.escape" "string.regexp" ] "cyan" { })
    (rule [ "constant.numeric" "constant.language" "constant.other" "support.constant" ] "orange" { })
    (rule [ "entity.name.function" "support.function" "meta.function-call" ] "blue" { })
    (rule [ "entity.name.type" "entity.name.class" "support.type" "support.class" "entity.other.inherited-class" ] "yellow" { })
    (rule [ "variable" "variable.other" "meta.definition.variable" ] "fg" { })
    (rule [ "variable.parameter" ] "fg" { fontStyle = "italic"; })
    (rule [ "variable.language" "variable.other.object.property" "variable.other.property" "support.variable.property" ] "cyan" { })
    (rule [ "entity.name.tag" ] "red" { })
    (rule [ "entity.other.attribute-name" ] "yellow" { })
    (rule [ "entity.name.namespace" "entity.name.module" ] "fg_dim" { })
    (rule [ "markup.heading" "entity.name.section" ] "primary" { fontStyle = "bold"; })
    (rule [ "markup.bold" ] "fg" { fontStyle = "bold"; })
    (rule [ "markup.italic" ] "fg" { fontStyle = "italic"; })
    (rule [ "markup.underline.link" "string.other.link" ] "blue" { })
    (rule [ "markup.inserted" ] "green" { })
    (rule [ "markup.deleted" ] "red" { })
    (rule [ "invalid" ] "red" { })
  ];

  themeJson = builtins.toJSON {
    name = "Closs";
    type = "dark";
    semanticHighlighting = true;
    inherit colors tokenColors;
    semanticTokenColors = {
      "parameter" = { foreground = c "fg"; italic = true; };
      "property" = c "cyan";
      "namespace" = c "fg_dim";
      "enumMember" = c "orange";
    };
  };

  packageJson = builtins.toJSON {
    name = "closs-theme";
    displayName = "Closs";
    publisher = "local";
    version = "1.0.0";
    engines.vscode = "^1.70.0";
    categories = [ "Themes" ];
    contributes.themes = [{
      label = "Closs";
      uiTheme = "vs-dark";
      path = "./themes/closs-color-theme.json";
    }];
  };

  clossTheme = pkgs.vscode-utils.buildVscodeExtension {
    pname = "closs-theme";
    version = "1.0.0";
    vscodeExtPublisher = "local";
    vscodeExtName = "closs-theme";
    vscodeExtUniqueId = "local.closs-theme";
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/$installPrefix/themes"
      cp ${pkgs.writeText "package.json" packageJson} "$out/$installPrefix/package.json"
      cp ${pkgs.writeText "closs-color-theme.json" themeJson} "$out/$installPrefix/themes/closs-color-theme.json"
      runHook postInstall
    '';
  };
in
{
  programs.vscode = {
    enable = true;
    # native Wayland (sharp text at fractional scale) with IME support;
    # Electron can't detect a keyring under Hyprland, so name it
    package = pkgs.vscode.override {
      commandLineArgs = "--ozone-platform-hint=auto --enable-wayland-ime --password-store=gnome-libsecret";
    };

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = [
        clossTheme
        pkgs.vscode-extensions.jnoortheen.nix-ide
      ];

      userSettings = {
        # look
        "workbench.colorTheme" = "Closs";
        "workbench.preferredDarkColorTheme" = "Closs";
        "workbench.iconTheme" = "vs-minimal";
        "workbench.productIconTheme" = "Default";
        "editor.fontFamily" = "'${theme.font.mono}', monospace";
        "editor.fontSize" = 14;
        "editor.lineHeight" = 1.6;
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "'${theme.font.mono}'";
        "terminal.integrated.fontSize" = 14;
        "editor.semanticHighlighting.enabled" = true;
        "editor.bracketPairColorization.enabled" = true;

        # chrome: as little as possible
        "window.titleBarStyle" = "custom";
        "window.commandCenter" = false;
        "window.menuBarVisibility" = "toggle"; # Alt shows it
        "window.controlsStyle" = "hidden";     # Hyprland closes windows
        "window.dialogStyle" = "custom";
        "window.title" = "\${rootName}\${separator}\${activeEditorShort}";
        "workbench.layoutControl.enabled" = false;
        "workbench.activityBar.location" = "top";
        "workbench.editor.tabActionLocation" = "right";
        "workbench.editor.tabSizing" = "shrink";
        "workbench.editor.showIcons" = false;
        "workbench.editor.empty.hint" = "hidden";
        "workbench.startupEditor" = "none";
        "workbench.tips.enabled" = false;
        "workbench.tree.indent" = 14;
        "workbench.tree.renderIndentGuides" = "onHover";
        "workbench.list.smoothScrolling" = true;
        "breadcrumbs.enabled" = false;
        "chat.commandCenter.enabled" = false;
        "explorer.compactFolders" = false;
        "explorer.decorations.badges" = false;

        # editor surface
        "editor.minimap.enabled" = false;
        "editor.stickyScroll.enabled" = false;
        "editor.glyphMargin" = false;
        "editor.folding" = true;
        "editor.showFoldingControls" = "mouseover";
        "editor.renderLineHighlight" = "line";
        "editor.overviewRulerBorder" = false;
        "editor.hideCursorInOverviewRuler" = true;
        "editor.scrollbar.verticalScrollbarSize" = 8;
        "editor.scrollbar.horizontalScrollbarSize" = 8;
        "editor.padding.top" = 12;
        "editor.guides.indentation" = true;
        "editor.renderWhitespace" = "none";
        "editor.lightbulb.enabled" = "off";
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.codeLens" = false;
        "scm.diffDecorations" = "gutter";

        # quiet
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.ignoreRecommendations" = true;
        "git.openRepositoryInParentFolders" = "never";
        "security.workspace.trust.enabled" = false;
      };
    };
  };
}
