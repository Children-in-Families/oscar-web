Rails.application.routes.draw do

  root 'statics#index'
  get '/robots.txt' => 'statics#robots'
  %w(404 500).each do |code|
    match "/#{code}", to: 'errors#show', code: code, via: :all
  end

  get '/dashboards' => 'dashboards#index'
  mount Thredded::Engine => '/forum'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

  get '/quantitative_data' => 'clients#quantitative_case'

  resources :agencies, except: [:show] do
    get 'version' => 'agencies#version'
  end

  scope 'admin' do
    resources :users do
      resources :user_custom_fields
      get 'version' => 'users#version'
      get 'disable' => 'users#disable'
    end
  end

  resources :quantitative_types do
    get 'version' => 'quantitative_types#version'
  end

  resources :quantitative_cases do
    get 'version' => 'quantitative_cases#version'
  end

  resources :referral_sources, except: [:show] do
    get 'version' => 'referral_sources#version'
  end

  resources :domain_groups, except: [:show] do
    get 'version' => 'domain_groups#version'
  end

  resources :domains, except: [:show] do
    get 'version' => 'domains#version'
  end

  resources :provinces, except: [:show] do
    get 'version' => 'provinces#version'
  end

  resources :departments, except: [:show] do
    get 'version' => 'departments#version'
  end

  resources :donors, except: [:show] do
    get 'version' => 'donors#version'
  end

  resources :changelogs do
    get 'version' => 'changelogs#version'
  end

  get '/data_trackers' => 'data_trackers#index'

  namespace :able_screens, path: '/' do
    namespace :question_submissions, path: '/' do
      resources :stages
      resources :able_screening_questions, except: [:index, :show]
    end

    namespace :answer_submissions do
      resources :clients do
        get 'able_screening_answers/new', to: 'able_screening_answers#new'
        post 'able_screening_answers/create', to: 'able_screening_answers#create'
      end
    end
  end

  resources :materials, except: [:show] do
    get 'version' => 'materials#version'
  end

  resources :locations, except: [:show] do
    get 'version' => 'locations#version'
  end

  resources :progress_note_types, except: [:show] do
    get 'version' => 'progress_note_types#version'
  end

  resources :interventions, except: [:show] do
    get 'version' => 'interventions#version'
  end

  resources :tasks, only: :index

  resources :clients do
    collection do
      get :advanced_search
    end
    resources :client_custom_fields
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

    resources :progress_notes do
      get 'version' => 'progress_notes#version'
    end

    collection do
      get '/find' => 'clients#find'
    end


    get 'version' => 'clients#version'
  end

  resources :attachments, only: [:index] do
    collection do
      get 'delete' => 'attachments#delete'
    end
  end

  resources :families do
    resources :family_custom_fields
    get 'version' => 'families#version'
  end

  resources :partners do
    resources :partner_custom_fields
    get 'version' => 'partners#version'
  end

  resources :notifications, only: [:index]

  namespace :api do
    mount_devise_token_auth_for 'User', at: '/v1/auth', skip: [:registrations, :passwords]

    resources :clients, only: [] do
      get :compare, on: :collection
    end
    resources :advanced_searches, only: [:index]

    namespace :v1, default: { format: :json } do
      resources :domain_groups, only: [:index]
      resources :clients, only: [:index] do

        resources :assessments, only: [:create]
        resources :tasks, only: [:create, :update]
        resources :case_notes, only: [:create]
      end
    end
  end

  scope '', module: 'form_builder' do
    resources :custom_fields
  end

  resources :papertrail_queries, only: [:index]

end
