module ActionDispatch
  module Routing
    class RouteSet

      def handle_storytime_urls(options)
        if options[:controller] == "storytime/posts" && options[:action] == "index"
          options[:use_route] = "root_post_index" if Storytime::Site.first.root_page_content == "posts"
        elsif options[:controller] == "storytime/posts" && options[:action] == "show"
          site = Storytime::Site.first
          key = [:id, :component_1, :component_2, :component_3].detect{|key| options[key].is_a?(Storytime::Post) }
          post = options[key]

          if post.is_a?(Storytime::Page)
            options[:component_1] = if post.post_category.nil? 
                                     nil 
                                   else 
                                    post.post_category.slug
                                  end
            options[:id] = post
          else

            case site.post_slug_style
            when "default"
              if post.post_category.nil? 
                options[:component_1] = "blog"
                options[:id] = post
               else 
                options[:component_1] = "blog"
                options[:component_2] = post.post_category.slug
                options[:id] = post
              end
            when "day_and_name" 
              date = post.created_at.to_date
              options[:component_1] = date.strftime("%Y") # 4 digit year
              options[:component_2] = date.strftime("%m") # 2 digit month
              options[:component_3] = date.strftime("%d") # 2 digit day
              options[:id] = post
            when "month_and_name"
              date = post.created_at.to_date
              options[:component_1] = date.strftime("%Y") # 4 digit year
              options[:component_2] = date.strftime("%m") # 2 digit month
              options[:id] = post
            when "post_id"
              options[:component_1] = "posts"
              options[:id] = post.id
            end
          end
        end
      end
      
      if Rails::VERSION::MINOR >= 2
        def url_for_with_storytime(options, route_name = nil, url_strategy = UNKNOWN)
          handle_storytime_urls(options)
          url_for_without_storytime(options, route_name, url_strategy)
        end
      else
        def url_for_with_storytime(options = {})
          handle_storytime_urls(options)
          url_for_without_storytime(options)
        end
      end

      alias_method_chain :url_for, :storytime

    end
  end
end