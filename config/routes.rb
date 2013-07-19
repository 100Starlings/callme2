require 'twiml_app'

Callme2::Application.routes.draw do
  root 'dashboard#index'
  mount TwimlApp, at: '/callme'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
