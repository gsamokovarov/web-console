# frozen_string_literal: true

class HelperTestController < ApplicationController
  def index
    @helper_test = "Helper Test"
  end
end
