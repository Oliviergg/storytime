class AddLanguageIdToSnippets < ActiveRecord::Migration
  def change
    add_column :storytime_snippets, :language_id, :integer
  end
end
