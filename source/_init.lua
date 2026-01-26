rtctime.set(0, 0)
wifi.setmode(wifi.NULLMODE, true)
print()

if file.exists('http.spar.new') == true then
  file.remove('http.spar')
  file.rename('http.spar.new', 'http.spar')
end

if file.exists('lfs.img.new') == true then
  file.remove('lfs.img')
  file.rename('lfs.img.new', 'lfs.img')
  node.LFS.reload('lfs.img')
end

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

_Util = require('_util')
_Time = require('_time')
_Fs = require('_fs')
require('_main')
