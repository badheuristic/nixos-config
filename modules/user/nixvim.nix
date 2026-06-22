{ config, pkgs, theme, inputs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.source = inputs.nixpkgs;
    nixpkgs.config.allowUnfree = true;

    globals.mapleader = " ";

    colorschemes.base16 = {
      enable = true;
      colorscheme = "grayscale-dark";
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
      conceallevel = 3;
    };

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "markdown" "text" "gitcommit" ];
        command = "setlocal wrap textwidth=80";
      }
      {
        event = [ "ColorScheme" "VimEnter" ];
        pattern = [ "*" ];
        command = "hi StatusLine guibg=NONE ctermbg=NONE | hi StatusLineNC guibg=NONE ctermbg=NONE";
      }
    ];

    extraConfigLua = ''
      vim.opt.isfname:append('@-@')
    '';

    plugins = {
      web-devicons.enable = true;
      which-key.enable = true;
      transparent = {
        enable = true;
        settings = {
          extra_groups = [ "StatusLine" "StatusLineNC" "lualine_c_normal" "lualine_c_inactive" ];
        };
      };
      lazygit.enable = true;
      tmux-navigator.enable = true;
      lualine = {
        enable = true;
        settings = {
          options = {
            component_separators = { left = ""; right = ""; };
            section_separators = { left = ""; right = ""; };
            theme = {
              __raw = ''
                (function()
                  local theme = require("lualine.themes.base16")
                  for _, mode in pairs({ "normal", "insert", "visual", "command", "replace", "inactive" }) do
                    if theme[mode] then
                      theme[mode].c = theme[mode].c or {}
                      theme[mode].c.bg = 'NONE'
                    end
                  end
                  return theme
                end)()
              '';
            };
          };
          sections = {
            lualine_a = pkgs.lib.mkForce [ { __unkeyed-1 = "mode"; separator = { left = ""; }; padding = { left = 1; right = 1; }; } ];
            lualine_b = pkgs.lib.mkForce [ "branch" "filename" ];
            lualine_c = pkgs.lib.mkForce [ { __unkeyed-1 = "%="; separator = ""; padding = 0; } ];
            lualine_x = pkgs.lib.mkForce [ "" ];
            lualine_y = pkgs.lib.mkForce [ "filetype" "progress" ];
            lualine_z = pkgs.lib.mkForce [ { __unkeyed-1 = "location"; separator = { right = ""; }; padding = { left = 1; right = 1; }; } ];
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
          marksman.enable = true; # Markdown
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
      { mode = "n"; key = "<leader>nn"; action = "<cmd>Ex ~/Notes<CR>"; options.desc = "open Notes"; }
      
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
