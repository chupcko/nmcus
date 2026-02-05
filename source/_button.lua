local button_class = _Util.class()

function button_class:constructor(pin, config)
  self.pin = pin
  self.config = config or {}
  if self.config.active_level == nil then
    self.config.active_level = 0
  end
  if self.config.debounce_us == nil then
    self.config.debounce_us = 30000
  end
  if self.config.multi_us == nil then
    self.config.multi_us = 400000
  end
  if self.config.repeat_us == nil then
    self.config.repeat_us = 200000
  end
  if self.config.pull == nil then
    self.config.pull = gpio.PULLUP
  end

  self.on_press = nil
  self.on_release = nil
  self.on_hold = nil
  self.on_clicks = nil

  self.last_edge_us = 0
  self.last_press_us = 0
  self.press_start_us = 0
  self.long_fired = false
  self.click_count = 0
  self.click_durations = {}

  self.long_timer = tmr.create()
  self.repeat_timer = tmr.create()
  self.multi_timer = tmr.create()

  gpio.mode(self.pin, gpio.INT, self.config.pull)
  gpio.trig(
    self.pin,
    'both',
    function(level)
      self:handle_edge(level)
    end
  )
end

function button_class:set_on_press(call)
  self.on_press = call
end

function button_class:set_on_release(call)
  self.on_release = call
end

function button_class:set_on_hold(call)
  self.on_hold = call
end

function button_class:set_on_clicks(call)
  self.on_clicks = call
end

function button_class:set_callbacks(calls_on)
  if type(calls_on) ~= 'table' then
    return
  end
  if type(calls_on.on_press) == 'function' then
    self.on_press = calls_on.on_press
  end
  if type(calls_on.on_release) == 'function' then
    self.on_release = calls_on.on_release
  end
  if type(calls_on.on_hold) == 'function' then
    self.on_hold = calls_on.on_hold
  end
  if type(calls_on.on_clicks) == 'function' then
    self.on_clicks = calls_on.on_clicks
  end
end

function button_class:handle_edge(level)
  local now_us = tmr.now()
  if now_us - self.last_edge_us < self.config.debounce_us then
    return
  end
  self.last_edge_us = now_us

  if level == self.config.active_level then
    self:handle_press(now_us)
  else
    self:handle_release(now_us)
  end
end

function button_class:handle_press(now_us)
  self.last_press_us = now_us
  self.press_start_us = now_us
  self.long_fired = false
  if type(self.on_press) == 'function' then
    self.on_press()
  end
  if type(self.on_hold) == 'function' then
    self.repeat_timer:alarm(
      math.floor(self.config.repeat_us / 1000),
      tmr.ALARM_AUTO,
      function()
        local now_us = tmr.now()
        self.on_hold(now_us - self.press_start_us)
      end
    )
  end
end

function button_class:handle_release(now_us)
  local duration_us = now_us - self.press_start_us
  self.repeat_timer:stop()
  if type(self.on_release) == 'function' then
    self.on_release(duration_us)
  end

  if type(self.on_clicks) == 'function' then
    self.click_count = self.click_count + 1
    table.insert(self.click_durations, duration_us)
    self.multi_timer:stop()
      self.multi_timer:alarm(
      math.floor(self.config.multi_us / 1000),
      tmr.ALARM_SINGLE,
      function()
        local count = self.click_count
        local durations = self.click_durations
        local total_us = 0
        for _, d in ipairs(durations) do
          total_us = total_us + d
        end
        self.click_count = 0
        self.click_durations = {}
        if count > 0 then
          self.on_clicks(count, total_us, durations)
        end
      end
    )
    return
  end
end

return button_class
