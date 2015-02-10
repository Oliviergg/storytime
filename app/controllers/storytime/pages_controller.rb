require_dependency "storytime/application_controller"

module Storytime
  class PagesController < ApplicationController
    before_action :ensure_site, unless: ->{ params[:controller] == "storytime/dashboard/sites" }

    def show
      lang = params[:id].match(/^fr|en/)
      I18n.locale = lang[0] unless lang.nil?
      @page = if request.path == "/"
        Page.published.find @site.root_post_id 
      elsif params[:preview]
        page = Page.find_preview(params[:id])
        page.content = page.autosave.content
        page.preview = true
        page
      else
        Page.published.friendly.find(params[:id].gsub("/","_"))
      end
      
      if params[:preview].nil? && ((params[:id].gsub("/","_") != @page.slug) && (request.path != "/"))
        return redirect_to @page, :status => :moved_permanently
      end

      #allow overriding in the host app
      render @page.slug if lookup_context.template_exists?("storytime/pages/#{@page.slug}")
    end
  end
end
