-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	commit = "cfc6f2c117aaaa82f19bcce44deec2c194d900ab", -- v0.9.3, for nvim 0.9.2+
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			-- add more arguments for adding more treesitter parsers
			"just",
			"markdown",
		},
		auto_install = true,
	},
}
