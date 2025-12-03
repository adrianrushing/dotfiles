return {
  "GCBallesteros/jupytext.nvim",
  config = function()
    require("jupytext").setup({
      style = "percent", -- Use # %% cell markers
      output_extension = "auto", -- Convert to .py automatically
      force_ft = "python", -- Force Python filetype for .ipynb
      custom_language_formatting = {
        python = {
          extension = "py",
          style = "percent",
          force_ft = "python",
        },
      },
    })
  end,
}
