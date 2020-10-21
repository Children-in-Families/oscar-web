Rails.application.routes.draw do

  root 'organizations#index'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  get '/robots.txt' => 'organizations#robots'

  %w(404 500).each do |code|
    match "/#{code}", to: 'errors#show', code: code, via: :all
  end

  get '/dashboards'     => 'dashboards#index', as: 'dashboards'
  post '/program_stream_services' => 'dashboards#update_program_stream_service', as: 'program_stream_services'
  get '/redirect'       => 'calendars#redirect', as: 'redirect'
  get '/callback'       => 'calendars#callback', as: 'callback'
  get '/calendar/sync'  => 'calendars#sync'

  resources :calendars

  # mount Thredded::Engine => '/forum'

  get '/quantitative_data' => 'clients#quantitative_case'

  resources :agencies, except: [:show] do
    get 'version' => 'agencies#version'
  end

  scope 'admin' do
    resources :users do
      resources :custom_field_properties
      resources :permissions
      get 'version' => 'users#version'
      get 'disable' => 'users#disable'
      # member do
      #   post :enable_multi_factor_authentication, to: 'users/multi_factor_authentication#verify_enable'
      #   post :disable_multi_factor_authentication, to: 'users/multi_factor_authentication#verify_disabled'
      # end
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
    collection do
      resources :custom_assessment_settings do
        resources :domains
      end
    end
  end

  # resources :provinces, except: [:show] do
  #   get 'version' => 'provinces#version'
  # end

  # resources :districts, except: [:show] do
  #   get 'version' => 'districts#version'
  # end

  resources :departments, except: [:show] do
    get 'version' => 'departments#version'
  end

  resources :organization_types, except: [:show] do
    get 'version' => 'organization_types#version'
  end

  resources :donors, except: [:show] do
    get 'version' => 'donors#version'
  end

  resources :program_streams do
    collection do
      get :search
      get :preview
    end
  end

  resources :changelogs do
    get 'version' => 'changelogs#version'
  end

  get '/data_trackers' => 'data_trackers#index'
  get 'clients/:client_id/book' => 'client_books#index', as: 'client_books'

  resources :clients do
    resources :referrals

    collection do
      post '/ad_search', to: 'clients#index'
      get :advanced_search
    end

    scope module: 'client' do
      resources :exit_ngos, only: [:create, :update]
      resources :enter_ngos, only: [:create, :update]
    end

    resources :client_enrollments do
      get :report, on: :collection
      resources :client_enrollment_trackings do
        get :report, on: :collection
      end
      resources :leave_programs
    end

    resources :client_enrolled_programs do
      get :report, on: :collection
      resources :client_enrolled_program_trackings do
        get :report, on: :collection
      end
      resources :leave_enrolled_programs
    end

    resources :custom_field_properties
    resources :government_forms
    resources :assessments
    resources :case_notes
    resources :cases do
      scope module: 'case' do
        resources :quarterly_reports, only: [:index, :show]
      end
    end
    scope module: 'client' do
      resources :tasks, except: [:new]
    end
    # resources :surveys
    get 'version' => 'clients#version'
  end

  resources :attachments, only: [:index] do
    collection do
      get 'delete' => 'attachments#delete'
    end
  end

  resources :calls do
    get '/edit/referee', to: 'calls#edit_referee'
  end
  resources :referees, only: [:index, :show]

  resources :families do
    resources :custom_field_properties
    get 'version' => 'families#version'
  end

  resources :partners do
    resources :custom_field_properties
    get 'version' => 'partners#version'
  end

  resources :notifications, only: [:index] do
    collection do
      get :program_stream_notify
      get :referrals
      get :repeat_referrals
    end
  end

  namespace :api do
    resources :referrals do
      get :compare, on: :collection
    end

    resources :referral_sources do
      get :get_referral_sources, on: :collection
      get :get_all_referral_sources, on: :collection
      get :referral_source_category, on: :collection
    end

    mount_devise_token_auth_for 'User', at: '/v1/auth', skip: [:passwords]

    mount_devise_token_auth_for 'AdminUser', at: 'v1/admin_auth'

    resources :form_builder_attachments, only: :destroy

    resources :provinces, only: :index do
      resources :districts, only: :index
    end

    resources :districts, only: [] do
      resources :communes, only: :index
    end

    resources :communes, only: [] do
      resources :villages, only: :index
    end

    resources :districts, only: :index do
      resources :subdistricts, only: :index
    end

    resources :states, only: :index do
      resources :townships, only: :index
    end

    resources :clients do
      get :compare, on: :collection
      get :render_client_statistics, on: :collection
      get :find_client_case_worker, on: :member
      post :assessments, on: :collection
      get :search_client, on: :collection
    end
    resources :custom_fields do
      collection do
        get :fetch_custom_fields
        get :ngo_custom_fields
        get :list_custom_fields
      end
      get :fields
    end
    resources :client_advanced_searches, only: [] do
      collection do
        get :get_custom_field
        get :get_basic_field
        get :get_enrollment_field
        get :get_tracking_field
        get :get_exit_program_field
      end
    end
    resources :calendars do
      get :find_event, on: :collection
    end
    resources :program_stream_add_rule, only: [] do
      collection do
        get :get_fields
      end
    end

    resources :program_streams, only: [:update] do
      get :enrollment_fields
      get :exit_program_fields
      get :tracking_fields
      collection do
        get :list_program_streams
      end
      collection do
        get :list_program_enrollments
      end
    end

    resources :domain_groups, only: [] do
      collection do
        get :get_domains_by_domain_groups
      end
    end

    # resources :referral_sources

    namespace :v1, default: { format: :json } do
      resources :organizations, only: [:index, :create, :update, :destroy] do
        collection do
          get :clients
          post 'clients/upsert' => 'organizations#upsert'
          get 'clients/check_duplication' => 'organizations#check_duplication'
          get 'transactions/:tx_id' => 'organizations#transaction'
          put 'clients/update_links' => 'organizations#update_link'
        end
      end

      resources :domain_groups, only: [:index]
      resources :departments, only: [:index]
      resources :families, only: [:index, :create, :update] do
        resources :custom_field_properties, only: [:create, :update, :destroy]
      end
      resources :users, only: [:index, :show]
      resources :clients, except: [:edit, :new] do
        resources :assessments, only: [:create, :update, :destroy, :delete]
        resources :case_notes, only: [:create, :update, :delete, :destroy]
        resources :custom_field_properties, only: [:create, :update, :destroy]

        scope module: 'clients' do
          resources :exit_ngos, only: [:create, :update]
          resources :enter_ngos, only: [:create, :update]
        end

        scope module: 'client_tasks' do
          resources :tasks, only: [:create, :update, :destroy]
        end
        resources :client_enrollments, only: [:create, :update, :destroy] do
          resources :client_enrollment_trackings, only: [:create, :update, :destroy]
          resources :leave_programs, only: [:create, :update, :destroy]
        end
      end

      resources :program_streams, only: [:index]
      resources :provinces, only: [:index]
      resources :birth_provinces, only: [:index]
      resources :districts, only: [:index]
      resources :communes, only: [:index]
      resources :villages, only: [:index]
      resources :donors, only: [:index]
      resources :agencies, only: [:index]
      resources :referral_sources do
        collection do
          get 'categories' => 'referral_sources#referral_source_parents'
        end
      end
      resources :domains, only: [:index]
      resources :quantitative_types, only: [:index]
      resources :settings, only: [:index]
      get 'translations/:lang' => 'translations#translation'

      resources :calls do
        get '/edit/referee', to: 'calls#edit_referee'
        put '/edit/referee', to: 'calls#update_referee'
      end
    end
  end

  namespace :multiple_form do
    resources :custom_fields, only: [] do
      resources :client_custom_fields, only: [:create, :new]
      resources :family_custom_fields, only: [:create, :new]
      resources :partner_custom_fields, only: [:create, :new]
      resources :user_custom_fields, only: [:create, :new]
    end
    resources :trackings, only: [] do
      resources :client_trackings, only: [:create, :new]
    end
    resources :program_streams do
      resources :client_enrollments
    end
  end

  scope '', module: 'form_builder' do
    resources :custom_fields do
      collection do
        get 'search' => 'custom_fields#search', as: :search
        get 'preview' => 'custom_fields#show', as: 'preview'
      end
    end
  end

  resources :advanced_search_save_queries
  # resources :client_advanced_searches, only: :index
  resources :papertrail_queries, only: [:index]

  resources :settings, except: [:destroy] do
    collection do
      get 'default_columns' => 'settings#default_columns'
      get 'research_module' => 'settings#research_module'
      get 'custom_labels' => 'settings#custom_labels'
      get 'client_forms' => 'settings#client_forms'
      get 'integration' => 'settings#integration'

      resources :field_settings, only: [:index] do
        collection do
          put :bulk_update
        end
      end
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
