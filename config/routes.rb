WebConsole::Engine.routes.draw do
  root 'console_sessions#index'

  resources :console_sessions
end
