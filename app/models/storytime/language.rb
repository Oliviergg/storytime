module Storytime
  class Language < ActiveRecord::Base
  	has_many :posts
  end
end
