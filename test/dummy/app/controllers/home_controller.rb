class HomeController < ApplicationController
  def index
    test = "Test"
    test_method
  end

  def test_method
    test2 = "Test2"
    raise
  end
end
