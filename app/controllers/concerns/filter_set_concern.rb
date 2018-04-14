module FilterSetConcern
  extend ActiveSupport::Concern

  def filter_conditions options={}
    OpenStruct.new(params[options[:key]||:filter_conditions].as_json)
  end
end

