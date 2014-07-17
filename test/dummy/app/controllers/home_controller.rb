class HomeController < ApplicationController
  def index
    test = "Test"
    @view_test = "View test"
    test_method
  end

  def test_method
    test2 = "Test2"
    # raise
  end
end
