local M = {}

-- Utilidades básicas
local function is_java()
  return vim.bo.filetype == 'java'
end

local function get_buf_lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function find_package_end(lines)
  -- Inserta imports después de la sentencia 'package ...;'
  for i, line in ipairs(lines) do
    if line:match('^package%s+[%w%._]+%s*;') then
      return i
    end
  end
  return 0
end

local function ensure_import(lines, import_stmt)
  for _, l in ipairs(lines) do
    if l:match('^%s*import%s+' .. vim.pesc(import_stmt) .. '%s*;') then
      return lines
    end
  end
  local idx = find_package_end(lines)
  table.insert(lines, idx + 1, 'import ' .. import_stmt .. ';')
  return lines
end

local function get_class_name(lines)
  for _, l in ipairs(lines) do
    local name = l:match('%f[%w][%w%s]*class%s+([%w_]+)')
    if name then return name end
  end
  return 'Entity'
end

local function find_class_line(lines)
  for i, l in ipairs(lines) do
    if l:match('%f[%w][%w%s]*class%s+[%w_]+') then return i - 1 end -- 0-index para LSP
  end
  return 0
end

local function pascal_case(name)
  return (name:gsub('(^%l)', string.upper):gsub('_(%l)', string.upper))
end

local function parse_fields(lines)
  local fields = {}
  for _, l in ipairs(lines) do
    -- ejemplo: private Long ldrEntityId;
    local type_, name = l:match('^%s*private%s+([%w_<>,%._]+)%s+([%w_]+)%s*;')
    if type_ and name then
      -- ignorar colecciones y estáticos/transient
      if not l:match('static') and not l:match('transient') then
        if not type_:match('List<') and not type_:match('Set<') and not type_:match('Map<') then
          table.insert(fields, { type_ = type_, name = name })
        end
      end
    end
  end
  return fields
end

local function find_annotation_block_start(lines)
  -- intenta colocar @NamedQueries encima de la declaración de clase
  local class_idx = 1
  for i, l in ipairs(lines) do
    if l:match('%f[%w][%w%s]*class%s+[%w_]+') then
      class_idx = i
      break
    end
  end
  -- Busca si ya existe @NamedQueries
  for i, l in ipairs(lines) do
    if l:match('@NamedQueries%(') then
      return i, true
    end
  end
  return class_idx - 1, false
end

local function add_named_queries()
  local lines = get_buf_lines()
  local class_name = get_class_name(lines)
  lines = ensure_import(lines, 'jakarta.persistence.NamedQuery')
  lines = ensure_import(lines, 'jakarta.persistence.NamedQueries')

  local fields = parse_fields(lines)
  if #fields == 0 then
    vim.notify('Java: No se detectaron campos privados para generar NamedQueries', vim.log.levels.WARN)
    return
  end

  local block_idx, exists = find_annotation_block_start(lines)
  local entries = {}
  for _, f in ipairs(fields) do
    local method = 'findBy' .. pascal_case(f.name)
    local q = string.format('    @NamedQuery(name = "%s.%s", query = "SELECT e FROM %s e WHERE e.%s = :%s")',
      class_name, method, class_name, f.name, f.name)
    table.insert(entries, q)
  end

  if exists then
    -- Insertar antes del cierre `})`
    local close_idx = nil
    for i = block_idx, math.min(block_idx + 80, #lines) do
      if lines[i]:match('%}%s*%)') then close_idx = i; break end
    end
    if not close_idx then close_idx = block_idx + 1 end
    -- Añadir una coma si el anterior no tiene
    if not lines[close_idx - 1]:match(',%s*$') then
      lines[close_idx - 1] = lines[close_idx - 1] .. ','
    end
    -- Preparar inserción con comas entre elementos; el último NO lleva coma
    local insertion = {}
    for i = 1, #entries do
      local line = entries[i]
      if i < #entries then line = line .. ',' end
      table.insert(insertion, line)
    end
    for i = #insertion, 1, -1 do
      table.insert(lines, close_idx, insertion[i])
    end
  else
    table.insert(lines, block_idx + 1, '@NamedQueries({')
    for i, e in ipairs(entries) do
      local line = e
      if i < #entries then line = line .. ',' end
      table.insert(lines, block_idx + 1 + i, line)
    end
    table.insert(lines, block_idx + 2 + #entries, '})')
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.notify('Java: @NamedQueries generados', vim.log.levels.INFO)
end

local function ensure_list_optional_imports(lines)
  local had = false
  local function has(import_stmt)
    for _, l in ipairs(lines) do
      if l:match('^%s*import%s+' .. vim.pesc(import_stmt) .. '%s*;') then return true end
    end
    return false
  end
  if not has('java.util.List') then lines = ensure_import(lines, 'java.util.List'); had = true end
  if not has('java.util.Optional') then lines = ensure_import(lines, 'java.util.Optional'); had = true end
  return lines, had
end

local function ensure_panache_imports(lines)
  local function has(import_stmt)
    for _, l in ipairs(lines) do
      if l:match('^%s*import%s+' .. vim.pesc(import_stmt) .. '%s*;') then return true end
    end
    return false
  end
  if not has('io.quarkus.hibernate.orm.panache.PanacheEntityBase') then
    lines = ensure_import(lines, 'io.quarkus.hibernate.orm.panache.PanacheEntityBase')
  end
  if not has('io.quarkus.panache.common.Parameters') then
    lines = ensure_import(lines, 'io.quarkus.panache.common.Parameters')
  end
  if not has('io.quarkus.hibernate.orm.panache.PanacheQuery') then
    lines = ensure_import(lines, 'io.quarkus.hibernate.orm.panache.PanacheQuery')
  end
  return lines
end

local function add_query_methods()
  local lines = get_buf_lines()
  local class_name = get_class_name(lines)
  lines, _ = ensure_list_optional_imports(lines)
  local fields = parse_fields(lines)
  if #fields == 0 then
    vim.notify('Java: No se detectaron campos privados para generar métodos', vim.log.levels.WARN)
    return
  end

  -- buscar la última llave de cierre de la clase
  local insert_idx = #lines
  for i = #lines, 1, -1 do
    if lines[i]:match('^%s*}%s*$') then
      insert_idx = i - 1
      break
    end
  end

  local methods = {}
  for _, f in ipairs(fields) do
    local Method = 'findBy' .. pascal_case(f.name)
    table.insert(methods, '')
    table.insert(methods, string.format('public static List<%s> %s(%s %s) {', class_name, Method, f.type_, f.name))
    table.insert(methods, string.format('    return find("%s", %s).list();', f.name, f.name))
    table.insert(methods, '}')

    local Single = 'findOneBy' .. pascal_case(f.name)
    table.insert(methods, string.format('public static java.util.Optional<%s> %s(%s %s) {', class_name, Single, f.type_, f.name))
    table.insert(methods, string.format('    return find("%s", %s).firstResultOptional();', f.name, f.name))
    table.insert(methods, '}')
  end

  for i = 1, #methods do
    table.insert(lines, insert_idx + i, methods[i])
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.notify('Java: métodos de consulta generados', vim.log.levels.INFO)
end

local function add_panache_methods()
  local lines = get_buf_lines()
  local class_name = get_class_name(lines)
  lines = ensure_panache_imports(lines)
  local fields = parse_fields(lines)
  if #fields == 0 then
    vim.notify('Java: No se detectaron campos privados para generar métodos Panache', vim.log.levels.WARN)
    return
  end

  local insert_idx = #lines
  for i = #lines, 1, -1 do
    if lines[i]:match('^%s*}%s*$') then insert_idx = i - 1 break end
  end

  local methods = {}
  for _, f in ipairs(fields) do
    local Method = 'findBy' .. pascal_case(f.name)
    table.insert(methods, '')
    table.insert(methods, string.format('public static PanacheQuery<%s> %s(%s %s) {', class_name, Method, f.type_, f.name))
    table.insert(methods, string.format('    return find("#%s.%s", Parameters.with("%s", %s));', class_name, Method, f.name, f.name))
    table.insert(methods, '}')

    local Single = 'findOneBy' .. pascal_case(f.name)
    table.insert(methods, string.format('public static java.util.Optional<%s> %s(%s %s) {', class_name, Single, f.type_, f.name))
    table.insert(methods, string.format('    return find("%s", %s).firstResultOptional();', f.name, f.name))
    table.insert(methods, '}')
  end

  for i = 1, #methods do table.insert(lines, insert_idx + i, methods[i]) end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.notify('Java: métodos Panache generados', vim.log.levels.INFO)
end

-- Code Action wrapper: mezcla acciones del LSP con acciones locales
function M.code_action()
  if not is_java() then
    return vim.lsp.buf.code_action()
  end

  -- Construye múltiples rangos y contextos para pedir la mayor cantidad de acciones posible
  local cur = vim.api.nvim_win_get_cursor(0)
  local lines = get_buf_lines()
  local class_line = find_class_line(lines)
  local function make_params(line, col, only)
    local r = {
      start = { line = line, character = col },
      ["end"] = { line = line, character = col },
    }
    local p = { textDocument = vim.lsp.util.make_text_document_params(), range = r }
    p.context = { diagnostics = vim.diagnostic.get(0), only = only }
    return p
  end

  local contexts = {
    nil,
    { "source" },
    { "source.organizeImports" },
    { "refactor" },
    { "refactor.extract" },
    { "refactor.inline" },
    { "refactor.rewrite" },
    { "quickfix" },
  }

  local ranges = {
    make_params(cur[1] - 1, cur[2], nil),
    make_params(class_line, 0, nil),
    make_params(0, 0, nil),
  }

  local items = {}
  local lsp_actions = {}

  table.insert(items, '[Local] Add NamedQueries for all fields')
  table.insert(items, '[Local] Add Query Methods (List/Optional)')
  table.insert(items, '[Local] Add PanacheQuery Methods (Quarkus)')

  local seen = {}
  for _, p in ipairs(ranges) do
    for _, only in ipairs(contexts) do
      p.context.only = only
      local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', p, 3000)
      for client_id, res in pairs(results or {}) do
        for _, action in ipairs(res.result or {}) do
          local title = type(action) == 'table' and action.title or tostring(action)
          if not seen[title] then
            seen[title] = true
            table.insert(lsp_actions, { client_id = client_id, action = action, title = title })
            table.insert(items, title)
          end
        end
      end
    end
  end

  vim.ui.select(items, { prompt = 'Code Actions' }, function(choice)
    if not choice then return end
    if choice:find('%[Local%] Add NamedQueries') then
      return add_named_queries()
    end
    if choice:find('%[Local%] Add Query Methods') then
      return add_query_methods()
    end
    if choice:find('%[Local%] Add PanacheQuery Methods') then
      return add_panache_methods()
    end
    -- Buscar acción LSP seleccionada por título
    local idx = 0
    for i, title in ipairs(items) do if title == choice then idx = i break end end
    local local_count = 3
    local lsp_idx = idx - local_count
    local entry = lsp_actions[lsp_idx]
    if not entry then return end
    local client = vim.lsp.get_client_by_id(entry.client_id)
    local action = entry.action
    if action.edit then
      local enc = (client and client.offset_encoding) or 'utf-16'
      vim.lsp.util.apply_workspace_edit(action.edit, enc)
    end
    if action.command then
      local command = type(action.command) == 'table' and action.command or action
      client.request('workspace/executeCommand', command, function() end)
    end
  end)
end

-- Menú sólo con nuestras acciones locales para no interferir con el UI del LSP
function M.menu()
  local items = {
    '[Local] Add NamedQueries for all fields',
    '[Local] Add Query Methods (List/Optional)',
    '[Local] Add PanacheQuery Methods (Quarkus)',
  }
  vim.ui.select(items, { prompt = 'Java Generators' }, function(choice)
    if not choice then return end
    if choice:find('NamedQueries') then return add_named_queries() end
    if choice:find('List/Optional') then return add_query_methods() end
    if choice:find('PanacheQuery') then return add_panache_methods() end
  end)
end

M.add_named_queries = add_named_queries
M.add_query_methods = add_query_methods

return M


