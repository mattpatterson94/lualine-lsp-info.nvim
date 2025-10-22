-- TypeScript/JavaScript LSP configurations
return {
  vtsls = {
    enabled = true,
    client_name = "vtsls",
    process_names = { "vtsls" },
    icon = "📦",
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
  typescript_tools = {
    enabled = true,
    client_name = "typescript-tools",
    display_name = "ts-tools",
    process_names = { "typescript-language-server", "node.*typescript" },
    icon = "⚡",
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
  tsserver = {
    enabled = true,
    client_name = "tsserver",
    process_names = { "tsserver" },
    icon = "📘",
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
  tsgo = {
    enabled = true,
    client_name = "tsgo",
    process_names = { "tsgo" },
    icon = "🚀",
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
}
