Rails.application.routes.draw do
  root "application#show"

  resources :parsing_files do
    get 'state', on: :member
  end

end
