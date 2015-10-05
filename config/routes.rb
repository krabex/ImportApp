Rails.application.routes.draw do
  root "application#show"

  resources :parsing_files, only: [:create] do
    get 'state', on: :member
  end

  resources :companies, only: [:index] do
    get 'stats', on: :member
  end

  resources :downloads, only: [:show] do
    get 'state', on: :member
  end
  post 'downloads/export_csv(/:filter)', to: 'downloads#export_csv'

end
