module Storytime
  class BlogPost < Post
    def get_younger_blog_post
      BlogPost.where('published_at > ?', self.published_at)&.order(:published_at)&.first
    end

    def get_older_blog_post
      BlogPost.where('published_at < ?', self.published_at)&.order(:published_at)&.last
    end

    def get_younger_blog_post_by_2
      BlogPost.where('published_at > ?', self.published_at)&.order(:published_at)&.first(2)&.last
    end

    def get_older_blog_post_by_2
      BlogPost.where('published_at < ?', self.published_at)&.order(:published_at)&.last(2)&.first
    end
  end
end
