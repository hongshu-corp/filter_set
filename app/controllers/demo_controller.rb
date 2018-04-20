class DemoController < ApplicationController
  @@filter_key = nil
  @@page_key = :page

  def self.filter_key= value
    @@filter_key = value
  end

  def self.page_key= value
    @@page_key = value
  end

  def name3
    ['good', 'bye']
  end

  def index
    @selected_conditions = filter_conditions @@filter_key
    @filter_action = filter_action
    @page = params[@@page_key]
    @name2 = ['hello', 'world']
    @source = ['bye']
  end
end

