class AddLangageToStorytimePost < ActiveRecord::Migration
  def change
    add_column :storytime_posts, :lang, :string
  end
end
