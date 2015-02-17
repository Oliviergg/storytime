module Storytime
  class PostCategory < ActiveRecord::Base
  	has_many :posts
  end
end
