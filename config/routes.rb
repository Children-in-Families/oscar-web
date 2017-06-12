Rails.application.routes.draw do

  root 'organizations#index'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

  get '/robots.txt' => 'organizations#robots'

  %w(404 500).each do |code|
    match "/#{code}", to: 'errors#show', code: code, via: :all
  end

  get '/dashboards' => 'dashboards#index'
  get '/redirect'       => 'calendars#redirect', as: 'redirect'
  get '/callback'       => 'calendars#callback', as: 'callback'
  get '/calendars/find' => 'calendars#find_event'
  get '/calendars/all_new' => 'calendars#all_new'

  resources :calendars, only: [:index, :new]

  mount Thredded::Engine => '/forum'

  get '/quantitative_data' => 'clients#quantitative_case'

  resources :agencies, except: [:show] do
    get 'version' => 'agencies#version'
  end

  scope 'admin' do
    resources :users do
      resources :custom_field_properties
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

  resources :program_streams

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
    resources :client_enrollments do
      get :report, on: :collection
      resources :client_enrollment_trackings do
        get :report, on: :collection
      end
      resources :leave_programs
    end
    resources :custom_field_properties
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

    get 'version' => 'clients#version'
  end

  resources :attachments, only: [:index] do
    collection do
      get 'delete' => 'attachments#delete'
    end
  end

  resources :families do
    resources :custom_field_properties
    get 'version' => 'families#version'
  end

  resources :partners do
    resources :custom_field_properties
    get 'version' => 'partners#version'
  end

  resources :notifications, only: [:index]

  namespace :api do
    mount_devise_token_auth_for 'User', at: '/v1/auth', skip: [:passwords]
    resources :clients do
      get :compare, on: :collection
    end
    resources :client_advanced_searches, only: [] do
      collection do
        get :get_custom_field
        get :get_basic_field
      end
    end
    resources :program_stream_add_rule, only: [] do
      collection do
        get :get_fields
      end
    end

    namespace :v1, default: { format: :json } do
      resources :domain_groups, only: [:index]
      resources :users, only: [:update]
      resources :clients, except: [:edit, :new] do
        get :compare, on: :collection
        resources :assessments, only: [:create]
        resources :case_notes, only: [:create]
        resources :custom_field_properties, only: [:create, :update, :destroy]

        scope module: 'client_tasks' do
          resources :tasks, only: [:create, :update, :destroy]
        end
      end
    end
  end


  scope '', module: 'form_builder' do
    resources :custom_fields do
      collection do
        get 'find'   => 'custom_fields#find'
        get 'search' => 'custom_fields#search', as: :search
        get 'preview' => 'custom_fields#show', as: 'preview'
      end
    end
  end

  resources :client_advanced_searches, only: :index
  resources :papertrail_queries, only: [:index]
end
