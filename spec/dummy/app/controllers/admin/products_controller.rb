module Admin

  class ProductsController < Alchemy::Admin::ResourcesController

    include AlchemyNodes::NodeablesControllerMixin

  end

end
