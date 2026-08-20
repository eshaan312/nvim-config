local cabs = { "W", "Wq", "WQ", "Wqa", "WQan", "WQA", "Q", "Q!", "Qq", "Wq!", "WQ!", "Wqa!", "WQA!", "QA", "Qa", "QA!", "Qa!" }
for _, cmd in ipairs(cabs) do
  vim.cmd("cabbrev " .. cmd .. " " .. cmd:lower())
end

vim.opt.ts = 4
vim.opt.sw = 4
vim.opt.sts = 4
vim.opt.et = true


vim.keymap.set('n', '<leader>te', function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  print("Diagnostics: " .. tostring(not enabled))

end, { desc = "Toggle diagnostics" })

vim.opt.number = true
vim.g.netrw_keepdir = 0
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.keymap.set({'n', 'v', 'i'}, '<PageUp>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<PageDown>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<S-Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<S-Down>', '<Nop>')
vim.opt.termguicolors = true

vim.keymap.set('n', '<C-e>', function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  print("Diagnostics: " .. tostring(not enabled))
end, { desc = "Toggle diagnostics" })
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "stevearc/overseer.nvim",
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    config = true,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        enable_check_bracket_line = false,
        map_cr = true,
        enable_moveright = true,
        disable_filetype = { "TelescopePrompt" },
      })
    end,
  },
{
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local dracula = require("dracula")
      dracula.setup({
        transparent_bg = false,
        italic_comments = true,
        show_end_of_buffer = true,
        colors = {
          bg = "#000000",
          -- Optional: adjust Dracula colors to fit a pitch-black theme if desired
        },
      })
      vim.cmd("colorscheme dracula")

      vim.cmd [[
        highlight Normal guibg=#000000 guifg=#f8f8f2
        highlight NormalNC guibg=#000000 guifg=#f8f8f2
        highlight Pmenu guibg=#000000 guifg=#8be9fd
        highlight PmenuSel guibg=#ff79c6 guifg=#f8f8f2 gui=bold
        highlight PmenuThumb guibg=#8be9fd
        highlight FloatBorder guibg=#000000 guifg=#8be9fd
        highlight NormalFloat guibg=#000000 guifg=#f8f8f2
      ]]
    end,
  },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config["clangd"] = {
        cmd = { "clangd", "--tweaks=-std=c++23" },
        capabilities = capabilities,
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      }
      vim.lsp.enable("clangd")

      vim.lsp.config["pyright"] = {
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
        capabilities = capabilities,
      }
      vim.lsp.enable("pyright")
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
  },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      vim.defer_fn(function()
        pcall(function()
          for _, lang in ipairs({ "c", "cpp", "lua", "python" }) do
            vim.cmd("TSInstall " .. lang)
          end
        end)
      end, 100)
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.formatting.black,
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },
})

vim.diagnostic.config({
  float = { border = "single" },
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "lua", "python" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.schedule(function()
      vim.cmd("normal! gg")
    end)
  end,
})
