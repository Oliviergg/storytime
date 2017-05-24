module Storytime
  class MediaUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Default resizes

    version :thumb do
      process resize_to_fit: [250, 150]
    end

    version :tiny do
      process resize_to_fit: [50, 50]
    end

    # Blog's posts' headers' images' resize

    version :blog_post_header do
      process resize_to_fill: [750, 250]
    end
  end
end
