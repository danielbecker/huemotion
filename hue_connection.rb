require 'httparty'
require 'logging'

class HueConnection
  include HTTParty
  format :json
  # debug_output $stdout

  def initialize(username, ip)
    self.class.base_uri "http://#{ip}/api/#{username}"
    @logger = Logging.logger(STDOUT)
  end

  def sensors
    response = self.class.get('/sensors').parsed_response
    response.select { |k, v| v['type'] == 'ZLLPresence' }.keys
  end

  def sensor_state(id)
    response = self.class.get("/sensors/#{id}").parsed_response
    response['state']['presence']
  end

  def lights
    response = self.class.get('/lights').parsed_response
  end

  def turn_light_on(id, bri=nil, ct=nil)
    data = { 'on' => true }
    data['bri'] = bri if bri
    data['ct'] = ct if ct
    response = self.class.put("/lights/#{id}/state", body: data.to_json)
    log_info response
  end

  def turn_light_off(id, bri=nil, ct=nil)
    data = { 'on' => false }
    data['bri'] = bri if bri
    data['ct'] = ct if ct
    response = self.class.put("/lights/#{id}/state", body: data.to_json)
    log_info response
  end

  def light_state(id)
    response = self.class.get("/lights/#{id}").parsed_response
    response['state']['on']
  end

private

  def timestamp
    Time.now.strftime '[%Y-%m-%d - %H:%M]'
  end

  def log_info(message)
    @logger.info "#{timestamp} #{message}"
  end
end