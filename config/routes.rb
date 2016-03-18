Rails.application.routes.draw do
  root "application#show"

  resources :parsing_files, only: [:create]

  resources :companies, only: [:index] do
    get 'stats', on: :member
  end

  resources :downloads, only: [:show]

  post 'downloads/export_csv(/:filter)', to: 'downloads#export_csv'

end
