return {
	"aznhe21/actions-preview.nvim",
	keys = {
		{
			"<leader>ca",
			function()
				require("actions-preview").code_actions()
			end,
			desc = "View Code Actions",
		},
	},

	config = function()
		require("actions-preview").setup({
			highlight_command = {
				require("actions-preview.highlight").delta(),
			},
		})
	end,
}
