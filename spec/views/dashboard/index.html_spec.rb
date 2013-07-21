require 'spec_helper'

describe "dashboard/index" do
  it "displays the currently on call agents" do
    assign(:agents, [stub_model(Agent, :name => "Adam")])

    render
    expect(rendered).to include("Adam")
  end
end
