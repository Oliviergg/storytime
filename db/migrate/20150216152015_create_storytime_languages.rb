class CreateStorytimeLanguages < ActiveRecord::Migration
  def change
    create_table :storytime_languages do |t|
      t.string :name
      t.string :lang

      t.timestamps
    end
  end
end
