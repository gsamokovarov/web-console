Rails.application.routes.draw do
  mount WebConsole::Engine => "/console"
end
