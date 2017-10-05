# frozen_string_literal: true

class ModelTestController < ApplicationController
  def index
    LocalModel.new.work
  end

  class LocalModel
    def initialize
      @state = :state
    end

    def work
      local_var = 42
      console
    end
  end
end
