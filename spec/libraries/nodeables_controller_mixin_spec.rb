require_relative '../../lib/alchemy_nodes/nodeables_controller_mixin'

class DummyController
  def self.append_view_path(*args);end
end

describe "NodeablesControllerMixin" do

  it "should add alchemy_nodes/nodeable/resources/ to view-path to have our views" do
    pending "Figure out how this could work"
    DummyController.should_receive(:append_view_path).with('/alchemy_nodes/resources')
    DummyController.send(:include, AlchemyNodes::NodeablesControllerMixin)
  end

end