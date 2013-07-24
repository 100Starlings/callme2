require 'sinatra/base'

class TwimlApp < Sinatra::Base
  enable :logging

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['CALLME_USER'] && password == ENV['CALLME_PASS']
  end


  get '/' do
    logger.info "New call"
    if Agent.on_call.empty?
      redirect "/callme/voicemail"
    else
      redirect "/callme/call/active"
    end
  end

  get '/call/:agents' do
    logger.info "Calling #{params[:agents]} agents"
    redirect "/callme/voicemail" unless ["active", "sleepers"].include?(params[:agents])
    agents = agents_to_dial(params[:agents])
    number_strings = numbers_to_dial(agents)do |number|
      "<Number url=\"http://#{ENV['CALLME_USER']}:#{ENV['CALLME_PASS']}@callmecplus.herokuapp.com/callme/screen\">#{number}</Number>"
    end

    response =<<EOF
  <Response>
    <Say voice='woman'>Hello, please wait while we connect you to #{agents.map(&:name).join(' and ')}. </Say>
    <Dial action="#{next_call(params[:agents])}" method="GET">
      #{number_strings.join("\n")}
    </Dial>
  </Response>
EOF
  end

  post '/screen' do
    logger.info "Screening call"
    reponse =<<EOF
  <Response>
    <Gather action="http://#{ENV['CALLME_USER']}:#{ENV['CALLME_PASS']}@callmecplus.herokuapp.com/callme/complete_call">
      <Say voice='woman'>Press any key to accept this call</Say>
    </Gather>
    <Hangup/>
  </Response>
EOF
  end

  post '/complete_call' do
    logger.info "Completing call"
    response =<<EOF
  <Response>
    <Say voice='woman'>Connecting</Say>
  </Response>
EOF
  end

  get '/voicemail' do
    logger.info "Activating Voicemail"
    response =<<EOF
  <Response>
    <Say voice='woman'>
      Welcome. Sorry our support team is not available at the moment.
      Please leave a message including your phone number or email address
      after the beep.
    </Say>  
    <Record action="/callme/recording" />
  </Response>
EOF
  end

  post '/recording' do
    recording_url = params['RecordingUrl']
    logger.info "Recording call at #{recording_url}"
    # email the recording url to the support team via sendhub.net ;)
    response =<<EOF
  <Response>
    <Say>Thank you for contacting us.  We'll be in touch shortly.  Goodbye.</Say>
    <Hangup/>
  </Response>
EOF
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
