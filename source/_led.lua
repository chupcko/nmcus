local led_class = _Util.class()

function led_class:constructor(pin, config)
  self.pin = pin
  self.config = config or {}
  if self.config.active_level == nil then
    self.config.active_level = 1
  end
  if self.config.pwm_freq == nil then
    self.config.pwm_freq = 1000
  end
  if self.config.pwm_max == nil then
    self.config.pwm_max = 1023
  end
  if self.config.use_pwm == nil then
    self.config.use_pwm = true
  end

  self.is_pwm = false
  self.timer = tmr.create()
  self.pattern = nil
  self.pattern_index = 1

  gpio.mode(self.pin, gpio.OUTPUT)
  self:off()
end

function led_class:enable_pwm()
  if self.config.use_pwm == false then
    return
  end
  if self.is_pwm == true then
    return
  end
  pwm.setup(self.pin, self.config.pwm_freq, 0)
  pwm.start(self.pin)
  self.is_pwm = true
end

function led_class:disable_pwm()
  if self.is_pwm == false then
    return
  end
  pwm.stop(self.pin)
  self.is_pwm = false
end

function led_class:stop()
  self.timer:stop()
  self.pattern = nil
  self.pattern_index = 1
  self.pattern_repeat = nil
  self.pattern_repeat_left = nil
end

function led_class:on()
  self:stop()
  self:disable_pwm()
  if self.config.active_level == 1 then
    gpio.write(self.pin, gpio.HIGH)
  else
    gpio.write(self.pin, gpio.LOW)
  end
end

function led_class:off()
  self:stop()
  self:disable_pwm()
  if self.config.active_level == 1 then
    gpio.write(self.pin, gpio.LOW)
  else
    gpio.write(self.pin, gpio.HIGH)
  end
end

function led_class:set_intensity(value)
  self:stop()
  if value == nil then
    return
  end
  if self.config.use_pwm == false then
    if value > 0 then
      self:on()
    else
      self:off()
    end
    return
  end

  local duty
  if value <= 1 then
    duty = math.floor(self.config.pwm_max * value)
  else
    duty = math.floor(value)
  end
  if duty < 0 then
    duty = 0
  elseif duty > self.config.pwm_max then
    duty = self.config.pwm_max
  end

  self:enable_pwm()
  if self.config.active_level == 1 then
    pwm.setduty(self.pin, duty)
  else
    pwm.setduty(self.pin, self.config.pwm_max - duty)
  end
end

function led_class:blink(on_ms, off_ms, intensity)
  self:stop()
  if on_ms == nil or off_ms == nil then
    return
  end
  if intensity == nil then
    intensity = 1
  end

  local state_on = false
  self.timer:alarm(
    on_ms,
    tmr.ALARM_AUTO,
    function()
      if state_on == true then
        state_on = false
        self:off()
        self.timer:interval(off_ms)
      else
        state_on = true
        self:set_intensity(intensity)
        self.timer:interval(on_ms)
      end
    end
  )
end

function led_class:pattern_start(steps, repeat_count)
  self:stop()
  if type(steps) ~= 'table' or #steps == 0 then
    return
  end
  self.pattern = steps
  self.pattern_index = 1
  if repeat_count ~= nil then
    self.pattern_repeat = repeat_count
    self.pattern_repeat_left = repeat_count
  end

  self.timer:alarm(
    1,
    tmr.ALARM_SINGLE,
    function()
      self:pattern_next()
    end
  )
end

function led_class:pattern_stop()
  self:stop()
end

function led_class:pattern_next()
  if self.pattern == nil then
    return
  end
  local step = self.pattern[self.pattern_index]
  if step == nil then
    if self.pattern_repeat ~= nil then
      self.pattern_repeat_left = self.pattern_repeat_left - 1
      if self.pattern_repeat_left <= 0 then
        self:stop()
        return
      end
    end
    self.pattern_index = 1
    step = self.pattern[self.pattern_index]
    if step == nil then
      return
    end
  end

  local duration = step[1]
  local intensity = step[2]
  if intensity == nil or intensity == 0 then
    self:off()
  else
    self:set_intensity(intensity)
  end

  self.pattern_index = self.pattern_index + 1
  self.timer:alarm(
    duration,
    tmr.ALARM_SINGLE,
    function()
      self:pattern_next()
    end
  )
end

return led_class
