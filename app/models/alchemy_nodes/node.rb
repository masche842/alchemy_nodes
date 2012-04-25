module AlchemyNodes
  class Node < ActiveRecord::Base
    self.table_name = "alchemy_nodes"

    belongs_to :nodeable, :polymorphic => true
    has_many :containers

    acts_as_nested_set

    validates_presence_of :page_layout, :message => '^' + I18n.t("Please choose a page layout.")

    def redirects_to_external?
      false
    end

    def current_container
      self.containers.first
    end

    class NoContainerError < RuntimeError
    end
  end
end
