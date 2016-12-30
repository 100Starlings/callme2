require "sinatra/base"
require "builder"

class TwimlApp < Sinatra::Base
  enable :logging

  use Rack::Auth::Basic, "Callme Twilio App" do |username, password|
    username == ENV["CALLME_USER"] && password == ENV["CALLME_PASS"]
  end

  get "/" do
    logger.info "New call"
    if agent_levels.empty?
      redirect to("/voicemail")
    else
      redirect to("/call/#{agent_levels.first}")
    end
  end

  get "/call/:level" do
    level = params[:level]
    logger.info "Calling level #{level} agents"
    redirect to("/voicemail") unless agent_levels.include?(level)
    agents = agents_to_dial(level)

    builder do |xml|
      xml.instruct! :xml, version: "1.0"
      xml.Response do
        names = agents.map(&:name).join(" and ")
        xml.Say "Hello, please wait while we connect you to #{names}",
          voice: "woman"
        xml.Dial action: next_call_url(level), method: "GET" do
          agents.pluck(:contact_number).each do |number|
            xml.Number number, dial_options
          end
        end
      end
    end
  end

  get "/call/:level/next" do
    level = params[:level]
    next_level = agent_levels.sort.find { |lvl| lvl > level }
    status = params["DialCallStatus"]

    if status == "completed"
      logger.info "Call completed, hanging up."
      builder do |xml|
        xml.instruct! :xml, version: "1.0"
        xml.Response do
          xml.Hangup
        end
      end
    elsif next_level
      redirect to("/call/#{next_level}")
    else
      redirect to("/voicemail")
    end
  end

  post "/screen" do
    logger.info "Screening call"
    builder do |xml|
      xml.instruct! :xml, version: "1.0"
      xml.Response do
        xml.Gather action: callme_complete_url do
          xml.Say "Press any key to accept this call", voice: "woman"
        end
        xml.Hangup
      end
    end
  end

  post "/complete_call" do
    logger.info "Completing call"
    builder do |xml|
      xml.instruct! :xml, version: "1.0"
      xml.Response do
        xml.Say "Connecting", voice: "woman"
      end
    end
  end

  get "/voicemail" do
    logger.info "Activating Voicemail"
    message = "Welcome. I am sorry, our support team is not available
      at the moment.
      Please leave a message including your phone number or email address
      after the beep. Press star when finished"
    builder do |xml|
      xml.instruct! :xml, version: "1.0"
      xml.Response do
        xml.Say message, voice: "woman"
        xml.Record action: "/callme/recording", timeout: 10, maxLength: "300"
      end
    end
  end

  post "/recording" do
    recording_url = params["RecordingUrl"]
    logger.info "Recording call at #{recording_url}"
    # email the recording url to the support team via sendhub.net ;)
    message = "Thank you for contacting us. We'll be in touch shortly. Goodbye"
    builder do |xml|
      xml.instruct! :xml, version: "1.0"
      xml.Response do
        xml.Say message
        xml.Hangup
      end
    end
  end

  post "/callback" do
    # save stats for the call
    Call.create(status_callback_params)
  end

  private

  def agent_levels
    Agent.on_call.pluck(:on_call_level)
  end

  def agents_to_dial(level)
    Agent.on_call.where(on_call_level: level)
  end

  def next_call_url(current_level)
    "#{base_url}/callme/call/#{current_level}/next"
  end

  def callme_screen_url
    "#{base_url}/callme/screen"
  end

  def callme_complete_url
    "#{base_url}/callme/complete_call"
  end

  def base_url
    "http://#{ENV["CALLME_USER"]}:#{ENV["CALLME_PASS"]}@#{request.host}"
  end

  def status_callback_params
    {
      sid:                params["CallSid"],
      from:               params["From"],
      to:                 params["To"],
      status:             params["CallStatus"],
      direction:          params["Direction"],
      duration:           params["CallDuration"],
      recording_url:      params["RecordingUrl"],
      recording_duration: params["RecordingDuration"],
    }
  end

  def numbers_to_dial(agents)
    Device.active.where(agent: agents).pluck(:address)
  end

  def screen_calls?
    screen_calls = ENV["CALLME_SCREEN_CALLS"]
    !["no", "off", 0].include? screen_calls
  end

  def dial_options
    options = {}
    options[:url] = callme_screen_url if screen_calls?

    options
  end
end
