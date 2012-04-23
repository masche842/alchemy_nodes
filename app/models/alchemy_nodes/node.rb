module AlchemyNodes
  class Node < ActiveRecord::Base
    self.table_name = "alchemy_nodes"

    belongs_to :nodeable, :polymorphic => true
    has_many :containers

    acts_as_nested_set

    validates_presence_of :page_layout, :message => '^' + I18n.t("Please choose a page layout.")

    class NoContainerError < RuntimeError
    end
  end
end
