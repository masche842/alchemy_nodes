module AlchemyNodes
  class Node < ActiveRecord::Base
    self.table_name = "alchemy_nodes"

    belongs_to :nodeable, :polymorphic => true

    acts_as_nested_set
  end
end
