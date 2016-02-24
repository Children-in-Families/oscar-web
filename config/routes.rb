Rails.application.routes.draw do
  resources :quarterly_reports
  devise_for :users, controllers: { registrations: 'registrations' }
  root 'clients#index'

  get '/robots.txt' => 'home#robots'

  resources :agencies

  scope 'admin' do
    resources :users
  end

  resources :quantitative_types
  resources :quantitative_cases
  resources :referral_sources
  resources :domain_groups
  resources :domains
  resources :provinces
  resources :departments
  resources :quarterly_reports, only: [:index]

  resources :tasks do
    collection do
      put 'set_complete'
    end
  end
  resources :clients do
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

  namespace :api, default: { format: :json } do
    resources :kinship_or_foster_care_cases, only: [] do
      resources :case_notes, only: [:index, :create]
      resources :case_notes_tasks, only: [:create, :update]
      resources :assessments, only: [:create]
    end
  end
end
