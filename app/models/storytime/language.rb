module Storytime
  class Language < ActiveRecord::Base
  	has_many :posts
  
  	def self.regexp
  		@_regexp ||= /#{Storytime::Language.all.map(&:lang).join("|")}/
  	end
  end
end
