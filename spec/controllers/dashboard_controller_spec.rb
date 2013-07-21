require 'spec_helper'

describe DashboardController do

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      expect(response).to be_success
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template :index
    end

    it "loads all on call agents into @agents" do
      FactoryGirl.create(:agent)
      on_call_agent = FactoryGirl.create(:on_call_agent)

      get :index

      expect(assigns(:agents)).to match_array([on_call_agent])
    end
  end

end
