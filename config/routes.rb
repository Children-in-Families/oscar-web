Rails.application.routes.draw do
  resources :quarterly_reports
  devise_for :users, controllers: { registrations: 'registrations' }
  root 'home#index'

  get '/robots.txt' => 'home#robots'

  resources :agencies, except: [:show]

  scope 'admin' do
    resources :users
  end

  resources :quantitative_types
  resources :quantitative_cases
  resources :referral_sources, except: [:show]
  resources :domain_groups, except: [:show]
  resources :domains, except: [:show]
  resources :provinces, except: [:show]
  resources :departments, except: [:show]
  resources :quarterly_reports, only: [:index]

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
  end

  

  resources :families
  resources :partners

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
