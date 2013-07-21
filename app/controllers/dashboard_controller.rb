class DashboardController < ApplicationController
  def index
    @agents = Agent.on_call
  end
end
