class CreateAlchemyContentFrames < ActiveRecord::Migration
  def change
    create_table :alchemy_content_frames do |t|

      t.timestamps
    end
  end
end
