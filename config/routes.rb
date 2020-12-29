# frozen_string_literal: true

Rails.application.routes.draw do
  match '(*any)',
        to: redirect(subdomain: ''),
        via: :all,
        constraints: ->(r) { r.subdomain.present? && r.subdomain != 'www' }

  root to: 'site#index'

  get '/signin', action: :new, controller: 'sessions', as: :sign_in
  delete '/signout', action: :destroy, controller: 'sessions', as: :sign_out
  get '/auth/github/callback', action: :create, controller: 'sessions'
  match '/auth/failure', to: 'sessions#failure', via: %i[get post delete]

  patch '/users/:id', to: 'users#update', as: :user
  delete '/users/:id', action: :destroy, controller: 'users'

  get '/settings', action: :index, controller: 'settings'

  get '/privacy', to: 'site#privacy'

  get 'staff', to: 'staff#index'
  require 'sidekiq/web'
  constraints ->(request) { StaffController.staff_request?(request) } do
    mount Sidekiq::Web => 'staff/sidekiq'
  end

  match '*unmatched_route', to: 'application#render404', via: :all
end
