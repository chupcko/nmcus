local util_module = {}

util_module.supers_access = function(data, data_key)
  for _, super in ipairs(data.__supers) do
    if super[data_key] ~= nil then
      return super[data_key]
    end
  end
  return nil
end

util_module.class = function(...)
  local new_class = {}
  new_class.__supers = { ... }
  if #new_class.__supers > 1 then
    setmetatable(new_class, new_class)
    new_class.__index = util_module.supers_access
  elseif #new_class.__supers == 1 then
    setmetatable(new_class, new_class)
    new_class.__index = new_class.__supers[1]
  end
  return new_class
end

util_module.new = function(class, ...)
  local new_instance = {}
  setmetatable(new_instance, new_instance)
  new_instance.__index = class
  new_instance.__class = class
  if type(class.constructor) == 'function' then
    result = new_instance:constructor(...)
    if result ~= nil then
      return result
    end
  end
  return new_instance
end

util_module.instance_of = function(instance, class)
  return instance.__class == class
end

util_module.to_string = function(data, add_cast_info)
  if add_cast_info == nil then
    add_cast_info = false
  end
  local out = {}
  if type(data) == 'table' then
    if add_cast_info then
      table.insert(out, ('(%s)'):format(tostring(data)))
    end
    table.insert(out, '{ ')
    local first = true
    for key, value in pairs(data) do
      if not first then
        table.insert(out, ', ')
      end
      table.insert(out, '[')
      table.insert(out, util_module.to_string(key, add_cast_info))
      table.insert(out, '] = ')
      table.insert(out, util_module.to_string(value, add_cast_info))
      first = false
    end
    table.insert(out, ' }')
  elseif type(data) == 'function' then
    if add_cast_info then
      table.insert(out, ('(%s)'):format(tostring(data)))
    end
  elseif type(data) == 'string' then
    table.insert(out, '\'')
    table.insert(out, (data:gsub('\\', '\\\\'):gsub('\'', '\\\'')))
    table.insert(out, '\'')
  else
    table.insert(out, tostring(data))
  end
  return table.concat(out)
end

util_module.string_to_hex = function(data)
  local out = {}
  for i = 1, data:len() do
    table.insert(out, ('%02x'):format(data:byte(i)))
  end
  return table.concat(out)
end

util_module.string_from_hex = function(...)
  local out = {}
  for _, data in ipairs({ ... }) do
    if type(data) == 'table' then
      for _, value in ipairs(data) do
        table.insert(out, util_module.string_from_hex(value))
      end
    elseif type(data) == 'string' then
      table.insert(out, data)
    elseif type(data) == 'number' then
      table.insert(out, string.char(data))
    end
  end
  return table.concat(out)
end

util_module.dump = function(...)
  local out = {}
  for _, argument in ipairs({ ... }) do
    table.insert(out, util_module.to_string(argument, true))
  end
  print(table.concat(out, ', '))
end

return util_module
