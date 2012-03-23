require 'spec_helper'

describe AlchemyNodes::Node do
  it "should act as a set" do
    AlchemyNodes::Node.should respond_to 'rebuild!'
  end
end
