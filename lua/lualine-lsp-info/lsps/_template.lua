-- Template for adding new language LSP configurations
-- Copy this file and rename it to your language (e.g., rust.lua, go.lua)
-- Then add your language module name to the lsp_modules list in init.lua

return {
  -- Example LSP configuration
  example_lsp = {
    enabled = true,                          -- Enable/disable this LSP
    client_name = "example_lsp",             -- Must match Neovim's LSP client name
    display_name = "example",                -- Optional: cleaner display name
    process_names = { "example-lsp-server" }, -- Process patterns to grep for memory monitoring
    icon = "🔧",                             -- Icon to display
    filetypes = { "example" },               -- Filetypes where this LSP applies
  },

  -- You can add multiple LSPs per language file
  another_lsp = {
    enabled = true,
    client_name = "another_lsp",
    process_names = { "another-server" },
    icon = "⚙️",
    filetypes = { "example", "example2" },
  },
}
