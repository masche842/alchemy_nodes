class CreateAlchemyNodesContainers < ActiveRecord::Migration
  def change
    create_table :alchemy_nodes_containers do |t|
      t.string :name
      t.string :urlname
      t.string :title
      t.string :meta_keywords
      t.string :meta_description
      t.boolean :robot_index
      t.boolean :robot_follow
      t.boolean :sitemap
      t.references :node
      t.references :language
      t.boolean :public
      t.boolean :locked
      t.integer :locked_by
      t.boolean :restricted

      t.userstamps
      t.timestamps
    end
    add_index :alchemy_nodes_containers, :node_id
    add_index :alchemy_nodes_containers, :language_id
  end
end
