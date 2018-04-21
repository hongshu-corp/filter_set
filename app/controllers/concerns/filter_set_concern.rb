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

    protected

    def render(options = nil, extra_options = {}, &block)
      if filter_action && filter_action.type == 'export' && !filter_action.rendered
        filter_action[:rendered] = true
        send_data send("export_to_#{filter_action.format}", parse_to_tables(data_for_export(options, extra_options, &block))), type: export_mime_type, filename: export_filename.encode("utf-8")
      else
        super options, extra_options, &block
      end
    end
  end

  protected

  def paginate rel, page_method: :paginate
    if filter_action && filter_action.paging.to_s.downcase != 'true'
      rel
    else
      rel.send page_method, params.slice(:page, :perpage)
    end
  end

  def data_for_export(options = nil, extra_options = {}, &block)
    if filter_action.template.blank?
      render_to_string options, extra_options, &block
    else
      locals = {}
      if filter_action.data_name.present?
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

  def parse_to_table doc, tab
    tab = tab.present? ? tab : 'table'
    row = filter_action.row_css || 'tr'
    cell = filter_action.cell_css || nil
    doc.css(tab).map do |table|
      table.css(row).map do |tr|
        (cell.present? ? tr.css(cell) : tr.xpath("td[not(contains(@class, 'no-export'))]|th[not(contains(@class, 'no-export'))]")).map do |cell|
          cell.text.strip
        end
      end
    end
  end

  def parse_to_tables content
    doc = Nokogiri::HTML(content)
    if filter_action.data_pattern
      filter_action.data_pattern.map do |data_css, _|
        tables = parse_to_table(doc, data_css)
        tables ? [data_css, tables] : nil
      end.compact.to_h
    else
      tables = parse_to_table(doc, filter_action.data_css)
      tables ? { filter_action.data_css => tables } : {}
    end
  end

  def export_to_csv tables
    CSV.generate do |csv|
      tables.values.flat_map{|tables| tables}.flat_map{|table| table}.each do |row|
        csv << row
      end
    end
  end

  def export_table_to_excel workbook, table, index, css=nil
    sheet = workbook[index]

    sheet_name = if index == 0
      filter_action.sheet_name
    end
    sheet_name ||= if css.present?
                     if filter_action.data_pattern
                       filter_action.data_pattern[css] || css
                     else
                      css
                     end
                   else
                     "Sheet#{index+1}"
                   end

    if sheet.nil?
      sheet = workbook.add_worksheet sheet_name
    else
      sheet.sheet_name = sheet_name
    end

    table.each_with_index do |tr, row_index|
      tr.each_with_index do |cell, cell_index|
        sheet.add_cell row_index, cell_index, cell
      end
    end
  end

  def export_to_excel tables_hash
    workbook = RubyXL::Workbook.new
    if tables_hash.keys[0].blank?
      tables_hash.values[0].each_with_index do |table, index|
        export_table_to_excel workbook, table, index
      end
    else
      tables_hash.each_with_index.each do |key_tables, index|
        css = key_tables.first
        table = key_tables.last.first
        export_table_to_excel workbook, table, index, css
      end
    end
    workbook.stream.string
  end
end

