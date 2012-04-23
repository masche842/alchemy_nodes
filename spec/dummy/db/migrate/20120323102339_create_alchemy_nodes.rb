class CreateAlchemyNodes < ActiveRecord::Migration
  def change
    create_table :alchemy_nodes do |t|
      t.string :name
      t.string :urlname
      t.string :page_layout
      t.boolean :layoutpage
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth
      t.references :nodeable, :polymorphic => true

      t.userstamps
      t.timestamps
    end
    add_index :alchemy_nodes, :parent_id
  end
end
