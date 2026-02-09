local consts = {
  ['name']                       = 'nmcus', -- CHANGE
  ['version']                    = '0.0',
  ['log.size']                   = 10,
  ['firmware.file_name']         = 'firmware.spar',
  ['firmware.file_name_new']     = 'firmware.spar.new',
  ['firmware.lfs_file_name']     = 'lfs.img',
  ['firmware.lfs_file_name_new'] = 'lfs.img.new',
  ['config.file_name']           = 'config.data',
  ['wifi.ap.mac']                = wifi.ap.getmac(),
  ['wifi.sta.mac']               = wifi.sta.getmac(),
  ['telnetd.port']               = 23,
  ['telnetd.timeout']            = 180,
  ['api.api_prefix']             = '/api/',
  ['api.ap.index_file']          = 'index.ap.html',
  ['api.sta.index_file']         = 'index.sta.html',
  ['httpd.port']                 = 80,
  ['httpd.timeout']              = 180,
  ['led.pin']                    = 4,
  ['button.pin']                 = 3
}

return consts
