rtctime.set(0, 0)
wifi.setmode(wifi.NULLMODE, true)
print()

package.loaders[4] = nil
package.loaders[3] = package.loaders[2]
package.loaders[2] = function(name)
  local module = node.LFS.get(name)
  if module ~= nil then
    return module
  end
  return ('\n\tno LFS module \'%s\''):format(name)
end

do

  local old_loadfile = loadfile
  loadfile = function(name)
    local module = node.LFS.get(name)
    if module ~= nil then
      return module
    end
    return old_loadfile(name)
  end

  dofile = function(name)
    return assert(loadfile(name))()
  end

end

_Consts = require('_consts')
_Util = require('_util')
_Fs = require('_fs')
_Log = _Util.new(require('_log'), _Consts['log.size'])

local have_new_lfs = false
if file.exists(_Consts['firmware.file_name_new']) == true then
  file.remove(_Consts['firmware.file_name'])
  file.rename(_Consts['firmware.file_name_new'], _Consts['firmware.file_name'])
  have_new_lfs = true
end

_Spar = _Util.new(require('_spar'), _Consts['firmware.file_name'], have_new_lfs)

if have_new_lfs then
  file.remove(_Consts['firmware.lfs_file_name_new'])
  _Spar:extract('/' .. _Consts['firmware.lfs_file_name'], _Consts['firmware.lfs_file_name_new']) --@ proveri
end

if file.exists(_Consts['firmware.lfs_file_name_new']) == true then
  file.remove(_Consts['firmware.lfs_file_name'])
  file.rename(_Consts['firmware.lfs_file_name_new'], _Consts['firmware.lfs_file_name'])
  node.LFS.reload(_Consts['firmware.lfs_file_name'])
end

file.remove(_Consts['firmware.lfs_file_name'])

print(('%s %s'):format(_Consts['name'], _Consts['version']))
print(125)

require('_main')
