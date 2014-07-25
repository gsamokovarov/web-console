Rails.application.routes.draw do
  root to: "exception_test#index"
  get :exception_test, to: "exception_test#index"
  get :helper_test, to: "helper_test#index"
end
