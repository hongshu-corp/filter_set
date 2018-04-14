module FilterSetConcern
  extend ActiveSupport::Concern

  def filter_conditions key=nil
    OpenStruct.new((params[key||:filter_conditions] || {}).as_json)
  end
end

