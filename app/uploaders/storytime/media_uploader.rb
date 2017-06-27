module Storytime
  class MediaUploader < CarrierWave::Uploader::Base
    include CarrierWave::ImageOptimizer
    include CarrierWave::MiniMagick

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    version :thumb do
      process resize_to_fit: [250, 150]
    end

    version :tiny do
      process resize_to_fit: [50, 50]
    end

    version :home_blog_post_header do
      process convert: 'jpg'
      process resize_to_fill: [350, 150]
      process optimize: [{ quality: 75 }]
    end

    version :blog_post_header do
      process convert: 'jpg'
      process resize_to_fill: [750, 320]
      process optimize: [{ quality: 75 }]
    end
  end
end
