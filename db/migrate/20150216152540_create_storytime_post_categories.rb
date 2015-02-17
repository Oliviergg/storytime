class CreateStorytimePostCategories < ActiveRecord::Migration
  def change
    create_table :storytime_post_categories do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
