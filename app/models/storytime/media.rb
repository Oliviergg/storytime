module Storytime
  class Media < ActiveRecord::Base
    belongs_to :user, class_name: Storytime.user_class
    has_many :posts

    mount_uploader :file, MediaUploader
  end
end
