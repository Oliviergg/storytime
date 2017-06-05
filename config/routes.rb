 Storytime::Engine.routes.draw do
  resources :comments
  resources :subscriptions, only: [:create]
  get 'subscriptions/unsubscribe', to: 'subscriptions#destroy', as: 'unsubscribe_mailing_list'

  namespace :dashboard, :path => Storytime.dashboard_namespace_path do
    get '/', to: 'posts#index'

    resources :sites, only: [:new, :edit, :update, :create]

    resources :posts do
      resources :autosaves, only: [:create]
    end

    resources :snippets, except: [:show]
    resources :media, except: [:show, :edit, :update]
    resources :imports, only: [:new, :create]
    resources :subscriptions
    resources :users, path: Storytime.user_class_underscore.pluralize

    resources :roles do
      collection do
        patch :update_multiple
      end
    end
  end

  get ':locale/blog/tags/:tag', to: 'blog_posts#index', as: :tag

  get Storytime.home_page_path, Storytime.home_page_route_options

  scope '/(:locale)', :locale => Storytime::Language.regexp do
    resources :blog_posts, path: '/blog', only: :index
  end

  # index page for post types that are excluded from primary feed
  constraints ->(request) {Storytime.post_types.any? {|type| type.constantize.type_name.pluralize == request.path.gsub('/', '')}} do
    get ':post_type', to: 'blog_posts#index'
  end

  # pages at routes like /about
  scope '/(:locale)', :locale => Storytime::Language.regexp do
    constraints -> (request) {
      page_name = request.params[:id]
      (page_name != Storytime.home_page_path) && Storytime::Page.friendly.exists?(page_name)
    } do
      get '/:category/:id', to: 'pages#show'
    end
  end

  scope '/(:locale)', :locale => Storytime::Language.regexp, constraints: ->(request) {request.params[:component_1] != 'assets'} do
    resources :posts, path: '(/:component_1(/:component_2(/:component_3)))/', only: :show, constraints: ->(request) {request.params[:component_1] != 'assets'}

    resources :posts, only: nil do
      resources :comments, only: [:create, :destroy]
    end
  end
end
