module AlchemyNodes
  module NodeablesControllerMixin
    def self.included(controller)
      controller.append_view_path 'alchemy_nodes/resources'
    end

  end
end