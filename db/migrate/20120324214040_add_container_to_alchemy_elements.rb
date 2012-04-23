class AddContainerToAlchemyElements < ActiveRecord::Migration
  def change
    add_column :alchemy_elements, :container_id, :integer
  end
end
