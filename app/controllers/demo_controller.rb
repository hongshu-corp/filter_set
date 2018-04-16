class DemoController < ApplicationController
  @@key = nil

  def self.key= value
    @@key = value
  end

  def index
    @selected_conditions = filter_conditions @@key
    @filter_action = filter_action
  end
end

