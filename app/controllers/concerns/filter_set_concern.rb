module FilterSetConcern
  extend ActiveSupport::Concern

  def filter_conditions key=nil
    OpenStruct.new((params[key||Rails.configuration.filter_set_key] || {}).as_json)
  end

  def filter_action
    OpenStruct.new(JSON(params[:submit])) if params[:submit]
  end
end

