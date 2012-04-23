module AlchemyNodes
  module NodeableMixin

    def self.included(model)
      model.send(:has_many, :nodes, :class_name => AlchemyNodes::Node, :as => :nodeable)
      model.send(:after_create, :create_root_node)
    end

    def create_root_node
      node = self.nodes.build
      #TODO stub for now, replace with something better...
      node.page_layout = 'standard'
      self.save
    end

  end
end