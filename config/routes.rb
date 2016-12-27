class LandingConstraint

  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www'
  end
end

Rails.application.routes.draw do

  root 'statics#index'
  get '/robots.txt' => 'statics#robots'

  # constraints LandingConstraint do
    get '/dashboards' => 'dashboards#index'
    mount Thredded::Engine => '/forum'

    # custom error pages
    %w(404 500).each do |code|
      match "/#{code}", to: 'errors#show', code: code, via: :all
    end

    resources :quarterly_reports
    devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

    get '/quantitative_data' => 'clients#quantitative_case'

    resources :agencies, except: [:show] do
      get 'version' => 'agencies#version'
    end

    scope 'admin' do
      resources :users do
        get 'version' => 'users#version'
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

    resources :quarterly_reports, only: [:index]

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

      resources :progress_notes do
        get 'version' => 'progress_notes#version'
      end

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
end
