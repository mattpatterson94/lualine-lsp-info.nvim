-- Java LSP configurations
return {
  jdtls = {
    enabled = true,
    client_name = "jdtls",
    process_names = { "jdtls", "java.*jdtls", "eclipse.jdt.ls" },
    icon = "☕",
    filetypes = { "java" },
  },
}
