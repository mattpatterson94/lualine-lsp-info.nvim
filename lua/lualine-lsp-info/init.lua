local M = {}

-- Load built-in LSP configurations from lsps/ directory
local function load_builtin_lsps()
  local builtin_lsps = {}

  -- List of built-in LSP modules to load
  local lsp_modules = { "typescript", "java" }

  for _, module_name in ipairs(lsp_modules) do
    local ok, lsp_config = pcall(require, "lualine-lsp-info.lsps." .. module_name)
    if ok then
      -- Merge LSPs from this module into builtin_lsps
      for lsp_key, lsp_def in pairs(lsp_config) do
        builtin_lsps[lsp_key] = lsp_def
      end
    end
  end

  return builtin_lsps
end

-- Built-in LSP configurations (loaded from lsps/ directory)
M.builtin_lsps = load_builtin_lsps()

-- Default global configuration
M.config = {
  -- Memory thresholds in MB
  thresholds = {
    high = 2048,   -- Above this shows warning and red color
    medium = 1024, -- Above this shows in GB and orange color
  },

  -- Colors for different memory levels
  colors = {
    high = "#f38ba8",   -- Red
    medium = "#fab387", -- Orange
    normal = nil,       -- Default lualine color
    client_name = "#89b4fa", -- Blue
  },

  -- Cache duration in seconds
  cache_duration = 30,

  -- Lualine integration settings
  lualine = {
    enabled = true,      -- Auto-register with lualine
    section = "lualine_x", -- Which section to add to
    position = 1,        -- Position in the section (1 = first)
  },

  -- Resolved LSP configurations (built-in + custom + overrides)
  lsps = {},
}

-- Resolve LSP configurations from built-in, custom, and user overrides
local function resolve_lsp_configs(opts)
  local resolved = {}

  -- Start with built-in LSPs
  for lsp_key, lsp_config in pairs(M.builtin_lsps) do
    local config = vim.tbl_deep_extend("force", {}, lsp_config)

    -- Apply user overrides for this built-in LSP
    if opts[lsp_key] then
      config = vim.tbl_deep_extend("force", config, opts[lsp_key])
    end

    -- Only include if enabled
    if config.enabled ~= false then
      resolved[config.client_name] = config
    end
  end

  -- Add custom LSPs
  if opts.custom then
    for lsp_key, lsp_config in pairs(opts.custom) do
      if lsp_config.client_name and lsp_config.enabled ~= false then
        resolved[lsp_config.client_name] = lsp_config
      end
    end
  end

  return resolved
end

local function get_lsp_client()
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if M.config.lsps[client.name] then
      return client, M.config.lsps[client.name]
    end
  end
  return nil, nil
end

local function get_memory_usage(client, lsp_config)
  local cache_key = "lsp_mem_cache_" .. client.name
  local cache_time_key = cache_key .. "_time"

  -- Return cached value if still valid
  if vim.g[cache_key] and (os.time() - (vim.g[cache_time_key] or 0)) <= M.config.cache_duration then
    return vim.g[cache_key]
  end

  -- Build grep pattern from LSP-specific process names
  local grep_pattern = table.concat(lsp_config.process_names, "|")
  local cmd = string.format(
    "ps aux | grep -E '%s' | grep -v grep | awk '{sum+=$6} END {print sum/1024}'",
    grep_pattern
  )

  local handle = io.popen(cmd)
  if not handle then
    return 0
  end

  local result = handle:read("*a")
  handle:close()

  local mem = tonumber(result) or 0
  vim.g[cache_key] = mem
  vim.g[cache_time_key] = os.time()

  return mem
end

-- Combined LSP info component (icon clientName (memUsage))
function M.component()
  return {
    function()
      local client, lsp_config = get_lsp_client()
      if not client or not lsp_config then
        return ""
      end

      local mem = get_memory_usage(client, lsp_config)
      if mem == 0 then
        return ""
      end

      -- Build display name from icon and name (use display_name if provided, otherwise client_name)
      local icon = lsp_config.icon or ""
      local name = lsp_config.display_name or client.name
      local display_name = icon ~= "" and string.format("%s %s", icon, name) or name

      -- Format memory based on size
      local mem_str
      if mem > M.config.thresholds.high then
        mem_str = string.format("%.1fG ⚠️", mem / 1024)
      elseif mem > M.config.thresholds.medium then
        mem_str = string.format("%.1fG", mem / 1024)
      else
        mem_str = string.format("%.0fM", mem)
      end

      return string.format("%s (%s)", display_name, mem_str)
    end,
    cond = function()
      local ft = vim.bo.filetype
      -- Check if any LSP supports this filetype
      for _, lsp_config in pairs(M.config.lsps) do
        if lsp_config.filetypes then
          for _, filetype in ipairs(lsp_config.filetypes) do
            if ft == filetype then
              return true
            end
          end
        end
      end
      return false
    end,
    color = function()
      local client = get_lsp_client()
      if not client then
        return M.config.colors.normal
      end

      local cache_key = "lsp_mem_cache_" .. client.name
      if vim.g[cache_key] then
        local mem = vim.g[cache_key]
        if mem > M.config.thresholds.high then
          return { fg = M.config.colors.high }
        elseif mem > M.config.thresholds.medium then
          return { fg = M.config.colors.medium }
        end
      end
      return M.config.colors.normal
    end,
  }
end


-- Setup function
function M.setup(opts)
  opts = opts or {}

  -- Extract global settings (non-LSP specific options)
  local global_opts = {}
  local reserved_keys = { "custom", "thresholds", "colors", "cache_duration", "lualine" }

  for key, value in pairs(opts) do
    if vim.tbl_contains(reserved_keys, key) then
      global_opts[key] = value
    end
  end

  -- Merge global settings
  M.config = vim.tbl_deep_extend("force", M.config, global_opts)

  -- Resolve LSP configurations (built-in + custom + overrides)
  M.config.lsps = resolve_lsp_configs(opts)

  -- Auto-register with lualine if enabled
  if M.config.lualine.enabled then
    vim.schedule(function()
      local ok, lualine = pcall(require, "lualine")
      if ok then
        local config = lualine.get_config()
        local section = config.sections[M.config.lualine.section]

        if section then
          -- Insert at the specified position
          table.insert(section, M.config.lualine.position, M.component())
          lualine.setup(config)
        end
      end
    end)
  end
end

return M
