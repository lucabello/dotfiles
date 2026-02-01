-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- My custom additions!
vim.opt.scrolloff = 12 -- scroll when close to the screen edges
vim.opt.shiftwidth = 2 -- convert typed Tab to n spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.cmd "set autoindent"
vim.cmd "setglobal expandtab"
vim.cmd "setglobal smartindent"
-- vim.cmd "set smarttab"
-- End of my custom additions

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    -- foo = "fooscript",
  },
  filename = {
    -- ["Foofile"] = "fooscript",
    ["justfile"] = "just",
    ["Justfile"] = "just",
  },
  pattern = {
    -- ["~/%.config/foo/.*"] = "fooscript",
    [".?[jJ]ustfile.*"] = "just",
    [".*%.just"] = "just",
  },
}
