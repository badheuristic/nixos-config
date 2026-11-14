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
      colorscheme = {
        base00 = "#${theme.bg}";
        base01 = "#${theme.surface}";
        base02 = "#${theme.surface2}";
        base03 = "#${theme.fg_faint}";
        base04 = "#${theme.fg_dim}";
        base05 = "#${theme.fg}";
        base06 = "#${theme.fg}";
        base07 = "#ffffff";
        base08 = "#${theme.red}";
        base09 = "#${theme.orange}";
        base0A = "#${theme.yellow}";
        base0B = "#${theme.green}";
        base0C = "#${theme.cyan}";
        base0D = "#${theme.blue}";
        base0E = "#${theme.magenta}";
        base0F = "#${theme.primary}";
      };
      settings = {
        transparent_mode = true;
      };
    };

    opts = {
      mouse = "";
      guicursor = "n-v-c:block-blinkon1-CursorInsert,i:block-CursorInsert";
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
      # vimichael: no sign gutter, no command bar
      signcolumn = "no";
      cmdheight = 0;
      updatetime = 50;
      colorcolumn = "80";
      conceallevel = 3;
      # vimichael: treesitter folding
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevel = 99;
      foldnestmax = 1;
      splitright = true;
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
      # vimichael: auto-equalize splits on resize
      {
        event = [ "VimResized" ];
        pattern = [ "*" ];
        command = "wincmd =";
      }
    ];

    extraConfigLua = ''
      vim.opt.isfname:append('@-@')
      -- vimichael: invisible split borders (panes distinguished by bg color only)
      vim.opt.fillchars = {
        vert = " ", horiz = " ", horizup = " ", horizdown = " ",
        vertleft = " ", vertright = " ", verthoriz = " "
      }
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
            # vimichael: flat text-only statusline, no powerline arrows
            component_separators = "";
            section_separators = "";
            icons_enabled = false;
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
          # vimichael layout: MODE | branch | filename ... encoding :: format :: filetype | progress | location
          sections = {
            lualine_a = pkgs.lib.mkForce [ "mode" ];
            lualine_b = pkgs.lib.mkForce [ "branch" ];
            lualine_c = pkgs.lib.mkForce [ "filename" ];
            lualine_x = pkgs.lib.mkForce [
              {
                __raw = ''
                  function()
                    local enc = vim.o.fileencoding
                    if enc == "" then
                      return vim.bo.fileformat .. " :: " .. vim.bo.filetype
                    else
                      return enc .. " :: " .. vim.bo.fileformat .. " :: " .. vim.bo.filetype
                    end
                  end
                '';
              }
            ];
            lualine_y = pkgs.lib.mkForce [ "progress" ];
            lualine_z = pkgs.lib.mkForce [ "location" ];
          };
          inactive_sections = {
            lualine_a = pkgs.lib.mkForce [];
            lualine_b = pkgs.lib.mkForce [];
            lualine_c = pkgs.lib.mkForce [ "filename" ];
            lualine_x = pkgs.lib.mkForce [ "location" ];
            lualine_y = pkgs.lib.mkForce [];
            lualine_z = pkgs.lib.mkForce [];
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
          "<Esc>" = "cmp.mapping(function(fallback) cmp.close(); fallback() end, {'i', 's'})";
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
            settings = {
              formatting.command = [ "nixfmt" ];
            };
          };
        };
        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
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
