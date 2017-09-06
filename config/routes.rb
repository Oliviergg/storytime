Storytime::Engine.routes.draw do
  resources :subscriptions, only: [:create]

  get 'subscriptions/unsubscribe', to: 'subscriptions#destroy', as: 'unsubscribe_mailing_list'

  namespace :dashboard, path: Storytime.dashboard_namespace_path do
    get '/', to: 'posts#index'

    resources :sites, only: %i[new edit update create]

    resources :posts do
      resources :autosaves, only: [:create]
    end

    resources :snippets, except: [:show]
    resources :media, except: %i[show edit update]
    resources :imports, only: %i[new create]
    resources :subscriptions
    resources :users, path: Storytime.user_class_underscore.pluralize

    resources :roles do
      collection do
        patch :update_multiple
      end
    end
  end

  scope '/:locale/blog' do
    get '/tags/:tag', to: 'blog_posts#index', as: :tag
    get '/:slug', to: 'blog_posts#show', as: :post
  end

  get Storytime.home_page_path, Storytime.home_page_route_options

  scope '/(:locale)', locale: Storytime::Language.regexp do
    resources :blog_posts, path: '/blog', only: :index
  end

  scope '/(:locale)', locale: Storytime::Language.regexp do
    constraints ->(request) {
      page_name = request.params[:id]
      (page_name != Storytime.home_page_path) && Storytime::Page.friendly.exists?(page_name)
    } do
      get '/:category/:id', to: 'pages#show'
    end
  end
end
