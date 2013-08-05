WebConsole::Engine.routes.draw do
  root to: 'console_sessions#index'

  resources :console_sessions
end
