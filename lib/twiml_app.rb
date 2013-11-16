require 'sinatra/base'
require 'builder'

class TwimlApp < Sinatra::Base
  enable :logging

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['CALLME_USER'] && password == ENV['CALLME_PASS']
  end

  get '/' do
    logger.info "New call"
    if Agent.on_call.empty?
      redirect to("/voicemail")
    else
      redirect to("/call/active")
    end
  end

  get '/call/:agents' do
    logger.info "Calling #{params[:agents]} agents"
    redirect to("/voicemail") unless ["active", "sleepers"].include?(params[:agents])
    agents = agents_to_dial(params[:agents])

    builder do |xml|
      xml.response do
        xml.say "Hello, please wait while we connect you to #{agents.map(&:name).join(' and ')}. ", voice: "woman" 
        xml.dial action: next_call(params[:agents]), method: "GET" do
          numbers_to_dial(agents).each do |number|
            xml.number number, url: "http://#{ENV['CALLME_USER']}:#{ENV['CALLME_PASS']}@#{request.host}/callme/screen"
          end
        end
      end
    end
  end

  post '/screen' do
    logger.info "Screening call"
    builder do |xml|
      xml.response do
        xml.gather action: "http://#{ENV['CALLME_USER']}:#{ENV['CALLME_PASS']}@#{request.host}/callme/complete_call" do
          xml.say "Press any key to accept this call", voice: "woman"
        end
        xml.hangup
      end
    end
  end

  post '/complete_call' do
    logger.info "Completing call"
    builder do |xml|
      xml.response do
        xml.say "Connecting", voice: "woman"
      end
    end
  end

  get '/voicemail' do
    logger.info "Activating Voicemail"
    message = "Welcome. I am sorry, our support team is not available at the moment.
      Please leave a message including your phone number or email address after the beep.
      Press star when finished"
    builder do |xml|
      xml.response do
        xml.say message, voice: "woman"
        xml.record action: "/callme/recording", timeout: 10, maxLength: "300"
      end
    end
  end

  post '/recording' do
    recording_url = params['RecordingUrl']
    logger.info "Recording call at #{recording_url}"
    # email the recording url to the support team via sendhub.net ;)
    builder do |xml|
      xml.response do
        xml.say "Thank you for contacting us.  We'll be in touch shortly.  Goodbye."
        xml.hangup
      end
    end
  end

  private

  def next_call(agents)
    case agents
    when 'active'
      '/callme/call/sleepers'
    when 'sleepers'
      '/callme/voicemail'
    end
  end

  def agents_to_dial(agents)
    case agents
    when 'active'
      Agent.on_call
    when 'sleepers'
      Agent.off_call
    end
  end

  def numbers_to_dial(agents)
    Device.active.where(agent_id: agents.map(&:id)).map(&:address)
  end
end
