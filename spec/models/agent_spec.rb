require 'spec_helper'

describe Agent do

  describe "validations" do
    context "being created" do
      it "requires a name" do
        expect(Factory.build(:agent)).to be_valid
        expect(Factory.build(:agent, name: nil)).to be_valid
      end

      it "requires an email" do
        expect(Factory.build(:agent, email: nil)).to be_invalid
      end

      it "requires the email to be in a valid format" do
        expect(Factory.build(:agent, email: "test")).to be_invalid
        expect(Factory.build(:agent, email: "test@xxx")).to be_invalid
      end
    end

    context "when trying to go on call" do
      let(:agent) { FactoryGirl.create(:agent) }

      it "requires at least one active device" do
        agent.on_call = true
        expect(agent.valid?).to be_false

        agent.devices.create(name: "phone", address: "555-12345", active: true)
        expect(agent.valid?).to be_true
      end
    end
  end
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

  describe ".off_call" do
    subject { Agent.off_call }
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

  describe "#on_call!" do
    let(:device) { FactoryGirl.create(:active_device) }
    let(:agent) { FactoryGirl.create(:agent, devices: [device]) }

    it 'marks the agent as being on call' do
      expect(agent.on_call).to be_nil
      expect(Agent.on_call).to have(0).records
      agent.on_call!
      expect(Agent.on_call).to have(1).record
      expect(agent.on_call).to be_true
    end
  end

  describe "#off_call!" do
    let(:agent) { FactoryGirl.create(:on_call_agent) }

    it 'marks the agent as being off call' do
      expect(agent.on_call).to be_true
      expect(Agent.on_call).to have(1).records
      agent.off_call!
      expect(Agent.on_call).to have(0).record
      expect(agent.on_call).to be_false
    end
  end

  describe "#on_call?" do
    let(:agent)         { FactoryGirl.create(:agent) }
    let(:on_call_agent) { FactoryGirl.create(:on_call_agent) }

    it "should be true for agents on call" do
      expect(agent.on_call?).to be_false
      expect(on_call_agent.on_call?).to be_true
    end
  end

  describe "#off_call?" do
    let(:agent)         { FactoryGirl.create(:agent) }
    let(:on_call_agent) { FactoryGirl.create(:on_call_agent) }

    it "should be true for agents not on call" do
      expect(agent.off_call?).to be_true
      expect(on_call_agent.off_call?).to be_false
    end
  end
end
