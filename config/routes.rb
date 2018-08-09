Rails.application.routes.draw do
  namespace :v1 do
    root 'welcome#index'
    get '/survivors/statistics', to: 'survivors#show_survivors_statistics'
    resources :survivors
    get '/survivors/:id/flag', to: 'survivors#flag_survivor'
  end
end
