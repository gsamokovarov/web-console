Rails.application.routes.draw do
  root to: "exception_test#index"
  get :exception_test, to: "exception_test#index"
  get :xhr_test, to: "exception_test#xhr"
  get :helper_test, to: "helper_test#index"
end
