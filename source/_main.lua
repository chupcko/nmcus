--@ REFACTORING BORDER

_Crypt = _Util.new(
  require('_crypt'),
  function()
    return ('%s = %s = %s'):format(_Consts['name'], _Consts['wifi.sta.mac'], 'secret'):reverse() -- CHANGE
  end
)

_Config = _Util.new(
  require('_config'),
  _Consts['config.file_name'],
  _Crypt,
  {
    ['wifi.mode']          = 'ap', -- 'ap' or 'sta'
    ['wifi.ap.ssid']       = ('%s - %s'):format(_Consts['name'], _Consts['wifi.ap.mac']:gsub(':', '')),
    ['wifi.ap.password']   = _Crypt:encrypt('12345678'), -- CHANGE
    ['wifi.ap.ip']         = '192.168.1.1',
    ['wifi.ap.netmask']    = '255.255.255.0',
    ['wifi.ap.gateway']    = '192.168.1.1',
    ['wifi.ap.dhcp_start'] = '192.168.1.100',
    ['wifi.sta.ssid']      = '',
    ['wifi.sta.password']  = _Crypt:encrypt(''),
    ['ntp.server']         = 'pool.ntp.org',
    ['telnetd.password']   = _Crypt:encrypt('secret'), -- CHANGE
    ['mqtt.host']          = '',
    ['mqtt.port']          = 8883,
    ['mqtt.tls']           = true,
    ['mqtt.cert']          = '',
    ['mqtt.key']           = '',
    ['mqtt.username']      = '',
    ['mqtt.password']      = '',
    ['mqtt.prefix']        = ('%s/'):format(_Consts['wifi.sta.mac']:gsub(':', ''))
  }
)

_Telnetd = _Util.new(
  require('_telnetd'),
  _Consts['telnetd.port'],
  _Consts['telnetd.timeout'],
  _Config:get('telnetd.password')
)

_Api = _Util.new(
  require('_api'),
  _Spar,
  _Consts['api.api_prefix'],
  function()
    if _Config:get('wifi.mode') == 'ap' then
      return _Consts['api.ap.index_file']
    end
    return _Consts['api.sta.index_file']
  end
)

_Httpd = _Util.new(
  require('_httpd'),
  _Consts['httpd.port'],
  _Consts['httpd.timeout'],
  _Api
)

_Time = require('_time')

_Network = require('_network')
_Network.registers_set(
  {
    ['sta_got_ip'] = function(result)
      _Time.sync()
      _Telnetd:start()
      _Httpd:start()
      print(('==IP %s'):format(result.IP))
    end
  }
)
_Network.start()

_Led = _Util.new(
  require('_led'),
  _Consts['led.pin'],
  {
    active_level = 0
  }
)

_Button = _Util.new(
  require('_button'),
  _Consts['button.pin']
)
_Button:set_callbacks(
  {
    on_press = function() print('==BUTTON PRESS') end,
    on_release = function(duration_us) print(('==BUTTON RELEASE %dus'):format(duration_us)) end,
    on_hold = function(duration_us) print(('==BUTTON HOLD %dus'):format(duration_us)) end,
    on_clicks = function(count, total_duration_us, durations)
      print(('==BUTTON CLICKS %d total=%dus'):format(count, total_duration_us))
      if durations ~= nil then
        print(('==BUTTON CLICKS DURATIONS %s'):format(_Util.to_string(durations)))
      end
    end
  }
)
