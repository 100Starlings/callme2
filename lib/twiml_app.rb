require "sinatra/base"
require "builder"

class TwimlApp < Sinatra::Base
  enable :logging

  use Rack::Auth::Basic, "Callme Twilio App" do |username, password|
    username == ENV["CALLME_USER"] && password == ENV["CALLME_PASS"]
  end

  get "/" do
    logger.info "New call"
    if Agent.on_call.empty?
      redirect to("/voicemail")
    else
      redirect to("/call/active")
    end
  end

  get "/call/:agents" do
    type = params[:agents]
    logger.info "Calling #{type} agents"
    redirect to("/voicemail") unless %w(active sleepers).include?(type)
    agents = agents_to_dial(type)

    builder do |xml|
      xml.response do
        names = agents.map(&:name).join(" and ")
        xml.say "Hello, please wait while we connect you to #{names}",
          voice: "woman"
        xml.dial action: next_call(type), method: "GET" do
          numbers_to_dial(agents).each do |number|
            xml.number number, url: callme_screen_url
          end
        end
      end
    end
  end

  post "/screen" do
    logger.info "Screening call"
    builder do |xml|
      xml.response do
        xml.gather action: callme_complete_url do
          xml.say "Press any key to accept this call", voice: "woman"
        end
        xml.hangup
      end
    end
  end

  post "/complete_call" do
    logger.info "Completing call"
    builder do |xml|
      xml.response do
        xml.say "Connecting", voice: "woman"
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
      xml.response do
        xml.say message, voice: "woman"
        xml.record action: "/callme/recording", timeout: 10, maxLength: "300"
      end
    end
  end

  post "/recording" do
    recording_url = params["RecordingUrl"]
    logger.info "Recording call at #{recording_url}"
    # email the recording url to the support team via sendhub.net ;)
    builder do |xml|
      xml.response do
        xml.say "Thank you for contacting us. We'll be in touch shortly. Goodbye"
        xml.hangup
      end
    end
  end

  post "/callback" do
    # save stats for the call
    Call.create(status_callback_params)
  end

  private

  def next_call(agents)
    case agents
    when "active"
      "/callme/call/sleepers"
    when "sleepers"
      "/callme/voicemail"
    end
  end

  def agents_to_dial(agents)
    case agents
    when "active"
      Agent.on_call
    when "sleepers"
      Agent.off_call
    end
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
end
