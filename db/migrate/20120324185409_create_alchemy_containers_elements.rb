class CreateAlchemyContainersElements < ActiveRecord::Migration

  def self.change
    create_table :alchemy_elements_alchemy_containers, :id => false do |t|
      t.integer :element_id
      t.integer :containers_id
    end
  end

end
