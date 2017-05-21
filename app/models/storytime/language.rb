module Storytime
  class Language < ActiveRecord::Base
  	has_many :posts
  
  	def self.default
  		@_default_lang = Storytime::Language.find_by_lang("fr")
  	end

  	def self.regexp
  		@_regexp ||= /fr|en|de|it|es|pt/
  		 # /#{Storytime::Language.all.map(&:lang).join("|")}/
  	end
  end
end
