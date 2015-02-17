class PopulateLanguage < ActiveRecord::Migration
  def change
  	Storytime::Language.create(name:"Français",lang:"fr")
  	Storytime::Language.create(name:"English",lang:"en")
  end
end
