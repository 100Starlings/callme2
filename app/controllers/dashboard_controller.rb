class DashboardController < ApplicationController
  def index
    @agents = Agent.on_call.order(:on_call_level)
  end
end
