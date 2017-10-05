# frozen_string_literal: true

class ControllerHelperTestController < ApplicationController
  def index
    @instance_variable = "Helper Test"
    local_variable = 42
    console
  end
end
