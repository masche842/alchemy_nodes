require 'spec_helper'
require_relative '../../lib/alchemy_nodes/nodeable_mixin'


describe "NodeableMixin" do

  it "should add an after_create-hook for 'create_root_node' to the including model" do
    Product.any_instance.should_receive(:create_root_node)
    product = Product.create
  end
  it "should add an has_many_nodes-hook to the including model" do
    product = Product.new
    product.should respond_to :nodes
  end

  describe "create_root_node" do
    it "should create a root node and attach it to nodeable" do
      product = Product.new
      product.create_root_node
      product.nodes.root.should be_an_instance_of AlchemyNodes::Node
    end
  end
end