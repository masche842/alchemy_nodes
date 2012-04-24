class CreateAlchemyContainersAlchemyElements < ActiveRecord::Migration

  def change
    create_table :alchemy_containers_alchemy_elements, :id => false do |t|
      t.integer :element_id
      t.integer :container_id
    end
  end

end
