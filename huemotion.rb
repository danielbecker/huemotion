#!/Users/db/.rvm/rubies/ruby-2.1.6/bin/ruby
require 'yaml'
require './hue_connection'

@config = YAML::load_file('config.yml')

connection = HueConnection.new(@config[:username], @config[:ip])
sensor_ids = connection.sensors
timeout_counter = 0

active = true

def current_timeslot_config
  @config[:timeslots].find do |slot|
    if slot[:start] < slot[:end]
      (slot[:start]..slot[:end]) === Time.now.hour
    else
      (slot[:start]..23) === Time.now.hour || (0..slot[:end]) === Time.now.hour
    end
  end
end

while active
  activity = sensor_ids.map do |sensor_id|
    connection.sensor_state(sensor_id)
  end

  if activity.include?(true)
    connection.turn_light_on(@config[:light_id], current_timeslot_config[:bri], current_timeslot_config[:ct]) unless connection.light_state(@config[:light_id])
    timeout_counter = @config[:timeout]
  elsif timeout_counter > 0
    timeout_counter -= 1
  else
    connection.turn_light_off @config[:light_id] if connection.light_state(@config[:light_id])
  end

  sleep 1
end

