# This migration comes from alchemy (originally 20120222152101)
class AddContainerToAlchemyCells < ActiveRecord::Migration
  def change
    add_column :alchemy_cells, :container_id, :integer
  end
end
