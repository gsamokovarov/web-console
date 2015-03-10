Rails.application.routes.draw do
  root to: "exception_test#index"

  get :exception_test, to: "exception_test#index"
  get :xhr_test, to: "exception_test#xhr"
  get :helper_test, to: "helper_test#index"
  get :helper_error, to: "helper_error#index"
  get :controller_helper_test, to: "controller_helper_test#index"

  namespace :tests do
    get :render_console_ontop_of_text
    get :renders_console_only_once
    get :doesnt_render_console_on_non_html_requests
  end
end
