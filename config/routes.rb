WebConsole::Engine.routes.draw do
  root to: 'console_sessions#index'

  resources :console_sessions do
    member do
      get :pending_output
      put :input
      put :interrupt
    end
  end
end
