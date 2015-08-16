class AgentMailer < ActionMailer::Base
  default from: ENV["MAIL_FROM"]

  def on_call(agent)
    @agent = agent
    mail to:      agent.email,
         subject: "[CallMe2] You are now on call"
  end

  def off_call(agent)
    @agent = agent
    mail to:      agent.email,
         subject: "[CallMe2] You are now off call"
  end
end
