WebConsole::Engine.routes.draw do
  root to: 'console_sessions#index'

  resources :console_sessions do
    member do
      put :input
      get :pending_output
      put :configuration
    end
  end

  resources :repl_sessions do
    member do
      post 'trace'
    end
  end
end
