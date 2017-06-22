module Storytime
  class BlogPostsController < ApplicationController
    before_action :ensure_site, unless: -> {params[:controller] === 'storytime/dashboard/sites'}

    caches_action :index, cache_path: -> { request.original_url.split("://", 2).last }, unless: :user_signed_in?
    caches_action :show, unless: :user_signed_in?

    def index
      if params[:tag].present?
        @tag = Tag.find_by(name: params[:tag])

        redirect_to blog_posts_path and return if @tag.nil?
      end

      @blog_posts = BlogPost.where_lang(I18n.locale).primary_feed
      @blog_posts = @blog_posts.tagged_with(@tag.name) if @tag.present?
      @blog_posts = @blog_posts.published.order(published_at: :desc).page(params[:page]).per(7)
    end

    def show
      @blog_post = BlogPost.find_by(slug: params[:slug])

      redirect_to blog_posts_path and return if @blog_post.nil?
      authorize @blog_post

      @other_posts = @blog_post.select_younger_and_older_posts
      @comments = @blog_post.comments.order('created_at DESC')

      if lookup_context.template_exists?("storytime/#{@blog_post.type_name.pluralize}/#{@blog_post.slug}")
        render "storytime/#{@blog_post.type_name.pluralize}/#{@blog_post.slug}"
      elsif lookup_context.template_exists?("storytime/#{@blog_post.type_name.pluralize}/show")
        render "storytime/#{@blog_post.type_name.pluralize}/show"
      end
    end
  end
end
