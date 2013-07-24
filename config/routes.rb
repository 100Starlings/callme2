require 'twiml_app'

Callme2::Application.routes.draw do
  root 'dashboard#index'
  mount TwimlApp, at: '/callme'
end
