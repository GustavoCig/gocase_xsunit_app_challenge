Rails.application.routes.draw do
  root 'welcome#index'
  resources :survivors
  get '/survivors/:id/flag', to: 'survivors#flag_survivor'
end
