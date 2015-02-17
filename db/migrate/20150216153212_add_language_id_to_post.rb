class AddLanguageIdToPost < ActiveRecord::Migration
  def change
    remove_column :storytime_posts, :lang
    add_column :storytime_posts, :language_id, :integer
  end
end
