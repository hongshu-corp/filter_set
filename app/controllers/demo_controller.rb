class DemoController < ApplicationController
  def self.key= value
    @@key = value
  end

  def index
    @selected_conditions = filter_conditions key: @@key
  end
end
