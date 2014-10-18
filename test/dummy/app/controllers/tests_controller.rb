class TestsController < ApplicationController
  def render_console_ontop_of_text
    render text: '<h1 id="greeting">Hello World</h1>'
    console
  end

  def renders_console_only_once
    render text: '<h1 id="greeting">Hello World</h1>'
    2.times { console }
  end

  def doesnt_render_console_on_non_html_requests
    render json: {}
    console
  end
end
