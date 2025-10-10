return {
    {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
        require("mason").setup()
    end,
    },
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim", -- auto-install debug adapters
			"nvim-neotest/nvim-nio", -- required by dap-ui
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "watches", size = 0.25 }, -- watch expressions window
							{ id = "scopes", size = 0.5 },
							{ id = "breakpoints", size = 0.25 },
						},
						size = 40,
						position = "left",
					},
				},
				floating = { border = "rounded" },
			})

			-- Virtual text
			require("nvim-dap-virtual-text").setup()

			-- Mason DAP (auto installs debug adapters)
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = { "python", "js" },
				handlers = {
					function(config)
						-- Default handler
						require("mason-nvim-dap").default_setup(config)
					end,
					python = function(config)
						require("mason-nvim-dap").default_setup(config)
						dap.adapters.python = {
							type = "executable",
							command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
							args = { "-m", "debugpy.adapter" },
						}
						dap.configurations.python = {
							{
								type = "python",
								request = "launch",
								name = "Launch file",
								program = "${file}",
								console = "integratedTerminal",
							},
						}
					end,
					js = function(config)
						require("mason-nvim-dap").default_setup(config)
						dap.adapters["pwa-node"] = {
							type = "server",
							host = "localhost",
							port = "${port}",
							executable = {
								command = "node",
								args = {
									vim.fn.stdpath("data")
										.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
									"${port}",
								},
							},
						}
						dap.configurations.javascript = {
							{
								type = "pwa-node",
								request = "launch",
								name = "Launch file",
								program = "${file}",
								cwd = vim.fn.getcwd(),
							},
						}
						dap.configurations.typescript = dap.configurations.javascript
					end,
				},
			})

			-- Open UI when debug session starts
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end

			-- Close UI when debug session ends safely
			dap.listeners.after.event_terminated["dapui_config"] = function(session)
				if session and session.initialized then
					dapui.close()
				end
			end

			dap.listeners.after.event_exited["dapui_config"] = function(session)
				if session and session.initialized then
					dapui.close()
				end
			end

			-- Keymaps
			local map = vim.keymap.set
			map("n", "<F5>", dap.continue, { desc = "DAP Continue" })
			map("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
			map("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
			map("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
			map("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP Conditional Breakpoint" })
			map("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
			map("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })
			map("n", "<leader>du", dapui.toggle, { desc = "DAP UI Toggle" })
		end,
	},
}
