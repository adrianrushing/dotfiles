return {
  "preservim/vim-markdown",
  ft = { "markdown", "quarto" },
  dependencies = {
    "godlygeek/tabular", -- Required for table formatting
  },
  init = function()
    -- Disable default key mappings
    vim.g.vim_markdown_no_default_key_mappings = 0

    -- Enable syntax highlighting for code blocks
    vim.g.vim_markdown_fenced_languages = {
      "python=py",
      "bash=sh",
      "javascript=js",
      "typescript=ts",
      "lua=lua",
      "vim=vim",
      "json=json",
      "yaml=yaml",
      "sql=sql",
      "r=r",
    }

    -- Other settings
    vim.g.vim_markdown_folding_disabled = 0 -- Enable folding
    vim.g.vim_markdown_folding_level = 2 -- Fold from level 2 headers
    vim.g.vim_markdown_toc_autofit = 1
    vim.g.vim_markdown_emphasis_multiline = 1
    vim.g.vim_markdown_conceal = 0 -- Disable concealing
    vim.g.vim_markdown_conceal_code_blocks = 0
    vim.g.vim_markdown_frontmatter = 1 -- YAML frontmatter
    vim.g.vim_markdown_toml_frontmatter = 1 -- TOML frontmatter
    vim.g.vim_markdown_json_frontmatter = 1 -- JSON frontmatter
    vim.g.vim_markdown_strikethrough = 1
    vim.g.vim_markdown_new_list_item_indent = 2
    vim.g.vim_markdown_auto_insert_bullets = 1
    vim.g.vim_markdown_edit_url_in = "tab" -- Open URLs in new tab
  end,
  config = function()
    -- Additional keybindings for markdown navigation
    vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader", { desc = "Next Header", buffer = true })
    vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader", { desc = "Previous Header", buffer = true })
    vim.keymap.set("n", "][", "<Plug>Markdown_MoveToNextSiblingHeader", { desc = "Next Sibling Header", buffer = true })
    vim.keymap.set(
      "n",
      "[]",
      "<Plug>Markdown_MoveToPreviousSiblingHeader",
      { desc = "Previous Sibling Header", buffer = true }
    )
    vim.keymap.set("n", "]u", "<Plug>Markdown_MoveToParentHeader", { desc = "Parent Header", buffer = true })
  end,
}
