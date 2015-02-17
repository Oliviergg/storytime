class AddPostCategoryIdToPost < ActiveRecord::Migration
  def change
    add_column :storytime_posts, :post_category_id, :integer
  end
end
