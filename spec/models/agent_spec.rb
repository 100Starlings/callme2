require 'spec_helper'

describe Agent do
  describe ".on_call" do
    subject { Agent.on_call }
    context "when there are no agents defined" do
      it { should be_empty }
    end
    context "when there are no agents on call" do
      before do
        FactoryGirl.create :agent
      end

      it { should be_empty }
    end

    context "when there are agents on call" do
      let (:adam) { FactoryGirl.create(:on_call_agent, name: "Adam") }
      let (:eve)  { FactoryGirl.create(:on_call_agent, name: "Eve")  }
      let (:john) { FactoryGirl.create(:agent) }

      it { should include(adam) }
      it { should include(eve) }
      it { should_not include(john) }
    end
  end

  describe ".not_on_call" do
    subject { Agent.not_on_call }
    context "when there are no agents defined" do
      it { should be_empty }
    end

    context "when there are no agents on call" do
      let(:john) { FactoryGirl.create(:agent) }

      it { should include(john) }
    end

    context "when there are agents on call" do
      let (:adam) { FactoryGirl.create(:on_call_agent, name: "Adam") }
      let (:eve)  { FactoryGirl.create(:on_call_agent, name: "Eve")  }
      let (:john) { FactoryGirl.create(:agent) }

      it { should_not include(adam) }
      it { should_not include(eve) }
      it { should include(john) }

    end
  end
end
