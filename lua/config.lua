local M = {}

M.setup = function(config)
	config = vim.tbl_deep_extend("force", {
		-- Default configuration
		highlight = "Comment",
		char = "│",
		space_char = " ",
		branch_char = "├",
		last_branch_char = "└",
	}, config or {})

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*.dart",
		callback = function()
			vim.cmd("setlocal list")
			vim.cmd("setlocal listchars=tab:>-,trail:~,extends:>,precedes:<,space:·")
			vim.cmd("setlocal indentexpr=")
			vim.cmd("setlocal indentkeys=")
			vim.cmd("setlocal foldmethod=expr")
			vim.cmd("setlocal foldexpr=FlutterTreeIndent()")
			vim.cmd("setlocal foldtext=FlutterTreeFoldText()")

			vim.fn["FlutterTreeIndent"] = function()
				local line = vim.fn.line(".")
				local level = vim.fn.indent(line) / 4
				local indent = ""
				local is_last = false

				for i = 1, level do
					if vim.fn.indent(line - 1) == (i - 1) * 4 then
						indent = indent .. config.branch_char .. config.space_char:rep(3)
					else
						indent = indent .. config.char .. config.space_char:rep(3)
					end
				end

				if vim.fn.indent(line + 1) <= level * 4 then
					is_last = true
					indent = indent:sub(1, -5) .. config.last_branch_char .. config.space_char:rep(3)
				end

				return indent
			end

			vim.fn["FlutterTreeFoldText"] = function()
				local line = vim.fn.foldclosedstart(vim.v.lnum)
				local level = vim.fn.indent(line) / 4
				local indent = ""

				for i = 1, level do
					if vim.fn.indent(line - 1) == (i - 1) * 4 then
						indent = indent .. config.branch_char .. config.space_char:rep(3)
					else
						indent = indent .. config.char .. config.space_char:rep(3)
					end
				end

				return indent .. vim.fn.getline(line)
			end
		end,
	})
end

return M
