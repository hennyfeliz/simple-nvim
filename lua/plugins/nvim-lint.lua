-- nvim-lint: Java desactivado (usaremos SonarLint-LS como linter)
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = lint.linters_by_ft or {}
		-- Sin linters para Java para evitar duplicados con SonarLint
		lint.linters_by_ft.java = {}
	end,
}




