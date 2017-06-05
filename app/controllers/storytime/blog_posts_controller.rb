require_dependency 'storytime/application_controller'

module Storytime
  class BlogPostsController < ApplicationController
    before_action :ensure_site, unless: -> {params[:controller] === 'storytime/dashboard/sites'}

    def index
      if params[:tag].present?
        @tag = Tag.find_by(name: params[:tag])

        redirect_to blog_posts_path and return if @tag.nil?
      end

      @posts = BlogPost.where_lang(I18n.locale).primary_feed
      @posts = @posts.tagged_with(@tag.name) if @tag.present?
      @posts = @posts.published.order(published_at: :desc).page(params[:page]).per(7)
    end

    def show
      @post = if params[:preview]
        post = Post.find_preview(params[:id])
        post.content = post.autosave.content
        post.preview = true
        post
      else
        Post.published.friendly.find(params[:id])
      end

      authorize @post

      if params[:preview].nil? && ((@site.post_slug_style != 'post_id') && (params[:id] != @post.slug))
        return redirect_to @post, :status => :moved_permanently
      end

      @other_posts = @post.select_younger_and_older_posts
      @comments = @post.comments.order('created_at DESC')

      if lookup_context.template_exists?("storytime/#{@post.type_name.pluralize}/#{@post.slug}")
        render "storytime/#{@post.type_name.pluralize}/#{@post.slug}"
      elsif lookup_context.template_exists?("storytime/#{@post.type_name.pluralize}/show")
        render "storytime/#{@post.type_name.pluralize}/show"
      end
    end
  end
end
