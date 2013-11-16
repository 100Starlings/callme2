require 'spec_helper'

describe Device do
  it "requires a name" do
    expect(FactoryGirl.build(:device, name: nil)).to be_invalid
  end

  it "requires an address" do
    expect(FactoryGirl.build(:device, address: nil)).to be_invalid
  end
end
