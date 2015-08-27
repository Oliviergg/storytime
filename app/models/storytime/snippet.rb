module Storytime
  class Snippet < ActiveRecord::Base
  	belongs_to :language

    validates :name, length: { in: 1..255 }
    validates :content, length: { in: 1..10000 }
    validates :language_id, presence: true
  end
end
