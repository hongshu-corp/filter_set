require 'csv'

module FilterSetConcern
  extend ActiveSupport::Concern

  def filter_conditions key=nil
    OpenStruct.new((params[key||Rails.configuration.filter_set_key] || {}).as_json)
  end

  def filter_action
    @filter_action ||=OpenStruct.new(JSON(params[Rails.configuration.filter_set_submit])) if params[Rails.configuration.filter_set_submit]
  end

  included do
    before_action do
      if filter_action && filter_action.paging.to_s.downcase != 'true'
        params.delete(Rails.configuration.filter_set_page_params)
      end
    end
  end

  protected

  def data_for_export(options = nil, extra_options = {}, &block)
    if filter_action.template.blank?
      render_to_string options, extra_options, &block
    else
      locals = {}
      unless filter_action.data_name.blank?
        if filter_action.data_source.blank?
          data = instance_variable_get("@#{filter_action.data_name}")||send(filter_action.data_name)
        else
          data = eval(filter_action.data_source)
        end
        locals = {filter_action.data_name.to_sym => data}
      end
      render_to_string partial: filter_action.template, locals: locals
    end
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

  def export_to_excel tables
    workbook = RubyXL::Workbook.new
    tables.each_with_index do |table, sheet_index|
      sheet = workbook[sheet_index]
      if sheet.nil?
        sheet = workbook.add_worksheet "Sheet#{sheet_index+1}"
      end

      table.each_with_index do |tr, row_index|
        tr.each_with_index do |cell, cell_index|
          sheet.add_cell(row_index, cell_index, cell)
        end
      end
    end
    workbook.stream.string
  end

  #todo export_to_excel
  #export table with css
  #export table to excel sheet name
end

