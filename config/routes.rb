Rails.application.routes.draw do
  mount Thredded::Engine => '/forum'

  # custom error pages
  %w(404 500).each do |code|
    match "/#{code}", to: 'errors#show', code: code, via: :all
  end

  resources :quarterly_reports
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root 'home#index'

  get '/robots.txt' => 'home#robots'
  get '/quantitative_data' => 'clients#quantitative_case'

  resources :agencies, except: [:show] do
    get 'version' => 'agencies#version'
  end

  post '/reports' => 'reports#index'
  resources :reports, only: [:index]

  scope 'admin' do
    resources :users do
      get 'version' => 'users#version'
    end
  end

  resources :quantitative_types
  resources :quantitative_cases
  resources :referral_sources, except: [:show]

  resources :domain_groups, except: [:show] do
    get 'version' => 'domain_groups#version'
  end

  resources :domains, except: [:show] do
    get 'version' => 'domains#version'
  end

  resources :provinces, except: [:show]

  resources :departments, except: [:show] do
    get 'version' => 'departments#version'
  end
  resources :quarterly_reports, only: [:index]
  resources :changelogs
  get '/data_trackers' => 'data_trackers#index'

  resources :tasks do
    collection do
      put 'set_complete'
    end
  end

  resources :clients do
    resources :government_reports
    resources :assessments
    resources :case_notes
    resources :cases do
      scope module: 'case' do
        resources :quarterly_reports, only: [:index, :show]
      end
    end
    scope module: 'client' do
      resources :tasks
    end
    resources :surveys
    get 'version' => 'clients#version'
  end

  

  resources :families do
    get 'version' => 'families#version'
  end

  resources :partners do
    get 'version' => 'partners#version'
  end

  namespace :api do
    mount_devise_token_auth_for 'User', at: '/v1/auth', skip: [:registrations, :passwords]
    namespace :v1, default: { format: :json } do
      resources :domain_groups, only: [:index]
      resources :clients, only: [:index] do
        resources :assessments, only: [:create]
        resources :tasks, only: [:create, :update]
        resources :case_notes, only: [:create]
      end
    end
  end
end
