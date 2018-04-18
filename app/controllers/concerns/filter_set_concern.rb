require 'csv'

module FilterSetConcern
  extend ActiveSupport::Concern

  def filter_conditions key=nil
    OpenStruct.new((params[key||Rails.configuration.filter_set_key] || {}).as_json)
  end

  def filter_action
    @filter_action ||=OpenStruct.new(JSON(params[:submit])) if params[:submit]
  end

  protected

  def data_for_export(options = nil, extra_options = {}, &block)
    #todo different slim
    render_to_string options, extra_options, &block
  end

  def render(options = nil, extra_options = {}, &block)
    if filter_action && filter_action.type == 'export' && !filter_action.rendered
      filter_action[:rendered] = true
      send_data send("export_to_#{filter_action.format}", parse_to_tables(data_for_export(options, extra_options, &block))), type: export_mime_type, filename: export_filename.encode("utf-8")
    else
      super options, extra_options, &block
    end
  end

  def export_filename
    export_filename_pattern+export_filename_suffix
  end

  def export_mime_type
    case filter_action.format.to_sym
    when :csv
      'text/csv'
    when :excel
      'application/excel'
    end
  end

  def export_filename_pattern
    Time.new.strftime("%Y%m%d%H%M%S")+SecureRandom.hex(1).upcase
  end

  def export_filename_suffix
    case filter_action.format.to_sym
    when :csv
      '.csv'
    when :excel
      '.xlsx'
    end
  end

  def parse_to_tables content
    docs = Nokogiri::XML(content)
    docs.xpath('//table').map do |table|
      table.xpath('tr|*/tr').map do |tr|
        tr.xpath("td[not(contains(@class, 'no-export'))]|th[not(contains(@class, 'no-export'))]").map do |cell|
          cell.text.strip
        end
      end
    end
  end

  def export_to_csv tables
    CSV.generate do |csv|
      tables.flat_map{|table| table}.each do |row|
        csv << row
      end
    end
  end

  #todo export_to_excel
end

