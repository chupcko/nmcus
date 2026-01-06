print()

wifi.setmode(wifi.NULLMODE, true)

if file.exists('lfs.img.new') then
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
require('_main')
