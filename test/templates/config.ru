require "action_view"
require "pathname"

TEST_ROOT = Pathname(__FILE__).dirname

class FakeMiddleware
  DEFAULT_HEADERS = {"Content-Type" => "application/javascript"}

  def initialize(opts)
    @headers        = opts.fetch(:headers, DEFAULT_HEADERS)
    @req_path_regex = opts[:req_path_regex]
    @view_path      = opts[:view_path]
  end

  def call(env)
    [200, headers, [render(req_path(env))]]
  end

  private

  attr_reader :headers
  attr_reader :req_path_regex
  attr_reader :view_path

  # extract target path from REQUEST_PATH
  def req_path(env)
    env["REQUEST_PATH"].match(req_path_regex)[1]
  end

  def render(template)
    view.render(template: template, layout: nil)
  end

  def view
    @view ||= create_view
  end

  def create_view
    lookup_context = ActionView::LookupContext.new(view_path)
    lookup_context.cache = false
    FakeView.new(lookup_context)
  end

  class FakeView < ActionView::Base
    def render_inlined_string(template)
      render(template: template, layout: "layouts/inlined_string")
    end
  end
end

# e.g. "/node_modules/mocha/mocha.js"
map "/node_modules" do
  node_modules = TEST_ROOT.join("node_modules")
  unless node_modules.directory?
    abort "ERROR: the node_modules/ directory is not found (You must run `npm install`)"
  end
  run Rack::Directory.new(node_modules)
end

# test runners
map "/html" do
  run FakeMiddleware.new(
    req_path_regex: %r{^/html/(.*)},
    headers: {"Content-Type" => "text/html"},
    view_path: TEST_ROOT.join("html"),
  )
end

map "/spec" do
  run FakeMiddleware.new(
    req_path_regex: %r{^/spec/(.*)},
    view_path: TEST_ROOT.join("spec"),
  )
end

map "/templates" do
  run FakeMiddleware.new(
    req_path_regex: %r{^/templates/(.*)},
    view_path: TEST_ROOT.join("../../lib/web_console/templates"),
  )
end
