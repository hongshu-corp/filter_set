class DemoController < ApplicationController
  def filter_key= value
    @filter_key = value
  end

  def name3
    ['good', 'bye']
  end

  def css_table= value
    @css_table = value
  end

  def table_class= value
    @table_class = value
  end

  def index
    @selected_conditions = filter_conditions @filter_key
    @filter_action = filter_action
    @page = params[Rails.configuration.filter_set_page_params]
    @name2 = ['hello', 'world']
    @source = ['bye']
  end
end

