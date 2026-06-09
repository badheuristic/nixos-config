{ config, pkgs, theme, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.config.allowUnfree = true;

    globals.mapleader = " ";

    colorschemes.base16 = {
      enable = true;
      customColorScheme = {
        base00 = "#${theme.bg}";
        base01 = "#${theme.bg_alt}";
        base02 = "#${theme.alt}";
        base03 = "#666666";
        base04 = "#888888";
        base05 = "#${theme.fg}";
        base06 = "#eeeeee";
        base07 = "#ffffff";
        base08 = "#aaaaaa";
        base09 = "#999999";
        base0A = "#bbbbbb";
        base0B = "#cccccc";
        base0C = "#dddddd";
        base0D = "#888888";
        base0E = "#777777";
        base0F = "#555555";
      };
      settings = {
        transparent_mode = true;
      };
    };

    opts = {
      mouse = "";
      guicursor = "";
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "80";
    };

    extraConfigLua = ''
      vim.opt.isfname:append('@-@')
    '';

    plugins = {
      web-devicons.enable = true;
      which-key.enable = true;
      transparent.enable = true;
      lazygit.enable = true;
      tmux-navigator.enable = true;
      lualine = {
        enable = true;
        settings = {
          options = {
            component_separators = { left = ""; right = ""; };
            section_separators = { left = ""; right = ""; };
          };
        };
      };
      
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = { action = "find_files"; options.desc = "find files"; };
          "<leader>fg" = { action = "git_files"; options.desc = "git files"; };
          "<leader>fw" = { action = "live_grep"; options.desc = "live grep"; };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
        settings.mapping = {
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };

      luasnip.enable = true;
      friendly-snippets.enable = true;
      luasnip.fromVscode = [{}];

      lsp = {
        enable = true;
        # Define language servers here instead of using Mason
        servers = {
          nil_ls.enable = true; # Nix
          bashls.enable = true;
          pyright.enable = true; # Python
          ts_ls.enable = true; # TypeScript
          clangd.enable = true;
          nixd = {
            enable = true;
            formatting.command = [ "nixfmt" ];
          };
        };
        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
        };
        lspBuf = {
          "K" = "hover";
          "gD" = "references";
          "gd" = "definition";
          "gi" = "implementation";
          "gt" = "type_definition";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-suda
    ];

    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>noh<CR>"; }
      { mode = "n"; key = "<leader>ex"; action = "<cmd>Ex<CR>"; options.desc = "netrw"; }
      { mode = "n"; key = "<leader>sr"; action = "<cmd>SudaRead<CR>"; options.desc = "read as root"; }
      { mode = "n"; key = "<leader>sw"; action = "<cmd>SudaWrite<CR>"; options.desc = "write as root"; }
      { mode = "n"; key = "<leader>ev"; action = ":ex "; }
      
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; }
      
      { mode = "n"; key = "n"; action = "nzzzv"; }
      { mode = "n"; key = "N"; action = "Nzzzv"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
      { mode = "n"; key = "<C-n>"; action = "<C-d>zz"; }
      { mode = "n"; key = "J"; action = "mzJ`z"; }
      
      { mode = "x"; key = "<leader>p"; action = "\"_dP"; }
      { mode = ["n" "v"]; key = "<leader>y"; action = "\"+y"; }
      { mode = "n"; key = "<leader>Y"; action = "\"+Y"; }
      { mode = ["n" "v"]; key = "<leader>d"; action = "\"_d"; }
      
      { mode = "n"; key = "Q"; action = "<nop>"; }
      { mode = "n"; key = "<C-k>"; action = "<cmd>cnext<CR>"; }
      { mode = "n"; key = "<C-j>"; action = "<cmd>cprev<CR>"; }
      { mode = "n"; key = "<leader>k"; action = "<cmd>lnext<CR>zz"; options.desc = "next on list"; }
      { mode = "n"; key = "<leader>j"; action = "<cmd>lprev<CR>zz"; options.desc = "prev on list"; }
      
      { mode = "n"; key = "<leader>fr"; action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/g<Left><Left>"; options.desc = "find and replace"; }
      { mode = "v"; key = "<leader>fr"; action = "\"hy:%s/<C-r>=escape(@h, \"/\\.*^$[]\")<CR>/<C-r>=escape(@h, \"/\\.*^$[]\")<CR>/g<Left><Left>"; options.desc = "find and replace"; }
      { mode = "n"; key = "<leader>x"; action = "<cmd>!chmod +x %<CR>"; options.silent = true; }

      { mode = "n"; key = "<leader>gs"; action = "<cmd>LazyGit<CR>"; options.desc = "lazygit"; }
    ];
  };
}
