module AlchemyNodes

  require 'alchemy_nodes/engine'

  require 'alchemy_nodes/nodeable_mixin'
  require 'alchemy_nodes/nodeables_controller_mixin'

  Engine.config.after_initialize do
    require 'alchemy_nodes/patches/elements_controller'
    Alchemy::Admin::ElementsController.send(:include, AlchemyNodes::Patches::ElementsController)
    Alchemy::Admin::ElementsController.send(:before_filter, :load_container_to_page, :only => [:index, :list, :new, :create])

    require 'alchemy_nodes/patches/element.rb'
  end

end


class ActionController::Base
  include AlchemyNodes
end
