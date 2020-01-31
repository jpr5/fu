# coding: utf-8
# Docs: https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
    root "root#index"

    resources :sessions, only: [:new, :create, :destroy]
    get 'login', to: 'sessions#new',      as: 'login'
    get 'logout', to: 'sessions#destroy', as: 'logout'
end
