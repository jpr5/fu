# coding: utf-8
# Docs: https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
    if $CONFIG.env == :development
        root "dev#index"
    end

    resources :sessions, only: [:new, :create, :destroy]

    get 'login', to: 'sessions#new', as: 'login'
    get 'logout', to: 'sessions#destroy', as: 'logout'
end
