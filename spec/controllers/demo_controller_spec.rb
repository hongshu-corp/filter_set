require 'rails_helper'
require 'csv'

RSpec.describe DemoController, type: :controller do
  describe 'get conditions object in controller' do
    it 'set default empty objects' do
      controller.filter_key = nil

      get :index

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new)
    end

    it 'get object by default key in params' do
      controller.filter_key = nil

      get :index, {filter_conditions: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end

    it 'get object by search params' do
      controller.filter_key = :my_conditions_key

      get :index, {my_conditions_key: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end

    it 'get object by hook' do
      controller.filter_key = nil
      allow(controller).to receive(:filter_text_object).and_return('Hello object')

      get :index, {filter_conditions: {text: 'Hello'}}

      expect(assigns(:selected_conditions).text_object).to eq 'Hello object'
    end
  end

  describe 'get submit type' do
    it 'action type with no scope' do
      get :index, {filter_submit: {type: :search}.to_json}

      expect(assigns(:filter_action)).to eq (OpenStruct.new(type: 'search'))
    end
  end

  describe 'default skip pagging args' do
    #it 'do not skip pagging params when no submit' do
      #get :index, {page: 1}

      #expect(assigns(:page)).to eq '1'
    #end

    #it 'skip pagging params when submit filter' do
      #get :index, {page: 1, filter_submit: {type: :search}.to_json }

      #expect(assigns(:page)).to eq nil
    #end

    #it 'keep page when submit current page' do
      #get :index, {page: 1, filter_submit: {type: :search, paging: true}.to_json }

      #expect(assigns(:page)).to eq '1'
    #end

    let(:model) { double 'model', paginate: '' }

    before do
      controller.params[:__page] = 2
      controller.params[:__per_page] = 30
    end

    it 'should paginate' do
      expect(model).to receive(:paginate).with(page: 2, per_page: 30)

      controller.params[Rails.configuration.filter_set_submit] = {type: :export, paging: true}.to_json
      controller.send :paginate, model
    end

    it 'should not paginate' do
      expect(model).not_to receive(:paginate)

      controller.params[Rails.configuration.filter_set_submit] = {type: :export, paging: false}.to_json
      controller.send :paginate, model
    end
  end

  describe 'export with csv' do
    render_views

    let(:csv) do
      CSV.generate do |csv|
        csv << ['a', 'b']
        csv << ['c', 'd']
      end
    end

    let(:filename) { 'csv' }

    before do
      allow(controller).to receive(:export_filename_pattern).and_return(filename)
      expect(controller).to receive(:send_data).with(csv.force_encoding('binary'), type: 'text/csv', filename: filename+'.csv')
    end

    it 'export data' do
      get :index, {filter_submit: {type: :export, format: :csv}.to_json}
    end

    describe 'export with custorm template' do
      let(:csv) do
        CSV.generate do |csv|
          csv << ['0', '1']
          csv << ['2', '3']
        end
      end

      specify do
        get :index, {filter_submit: {type: :export, format: :csv, template: 'export_table1'}.to_json}
      end
    end

    describe 'export with custorm template, data_name and same data source as @name' do
      let(:csv) do
        CSV.generate do |csv|
          csv << ['hello']
          csv << ['world']
        end
      end

      specify do
        get :index, {filter_submit: {type: :export, format: :csv, template: 'export_table2', data_name: 'name2'}.to_json}
      end
    end

    describe 'export with custorm template, data_name and same data source as name' do
      let(:csv) do
        CSV.generate do |csv|
          csv << ['good']
          csv << ['bye']
        end
      end

      specify do
        get :index, {filter_submit: {type: :export, format: :csv, template: 'export_table3', data_name: 'name3'}.to_json}
      end
    end

    describe 'export with custorm template, data_name and same data source as name' do
      let(:csv) do
        CSV.generate do |csv|
          csv << ['bye']
        end
      end

      specify do
        get :index, {filter_submit: {type: :export, format: :csv, template: 'export_table2', data_name: 'name2', data_source: '@source'}.to_json}
      end
    end

    describe 'export with css' do
      let(:table_class) { 'table_class' }
      let(:css_table) { ['hello', 'world'] }
      let(:csv) do
        CSV.generate do |csv|
          css_table.each do |r|
            csv << [r]
          end
        end
      end

      specify do
        controller.instance_variable_set(:@table_class, table_class)
        controller.instance_variable_set(:@css_table, css_table)
        get :index, {filter_submit: {type: :export, format: :csv, data_css: '.table_class'}.to_json}
      end
    end
  end

  describe 'export excel' do
    render_views
    let!(:workbook) { RubyXL::Workbook.new }
    let(:content) do
      workbook.worksheets.map do |sheet|
        [sheet.sheet_name, sheet.map do|r|
          r.cells.map(&:value)
        end]
      end.to_h
    end

    before do
      allow(RubyXL::Workbook).to receive(:new).and_return(workbook)
    end

    it 'export data' do
      get :index, {filter_submit: {type: :export, format: :excel}.to_json}

      expect(content).to eq({"Sheet1" => [['a', 'b'], ['c', 'd']]})
    end

    it 'export data with sheet_name' do
      get :index, {filter_submit: {type: :export, format: :excel, sheet_name: 'sheet'}.to_json}

      expect(content).to eq({'sheet' => [['a', 'b'], ['c', 'd']]})
    end

    describe 'export data with css' do
      let(:table_class) { 'table_class' }
      let(:css_table) { ['hello', 'world'] }

      before do
        controller.instance_variable_set(:@table_class, table_class)
        controller.instance_variable_set(:@css_table, css_table)
      end

      it 'export data with css' do
        get :index, {filter_submit: {type: :export, format: :excel, data_css: '.table_class'}.to_json}

        expect(content).to eq({".table_class" => [['hello'], ['world']]})
      end

      it 'export data with css and name' do
        get :index, {filter_submit: {type: :export, format: :excel, data_css: '.table_class', sheet_name: 'sheet'}.to_json}

        expect(content).to eq({"sheet" => [['hello'], ['world']]})
      end

      it 'export data with css-name pattern' do
        get :index, {filter_submit: {type: :export, format: :excel, data_pattern: {'.table_class': 'sheet'}}.to_json}

        expect(content).to eq({"sheet" => [['hello'], ['world']]})
      end

      it 'export data with css row and cell' do
        get :index, {filter_submit: {type: :export, format: :excel, data_css: '.table', row_css: '.tr', cell_css: '.td'}.to_json}

        expect(content).to eq({".table" => [['hello'], ['world']]})
      end
    end
  end

  context 'e2e' do
    render_views

    it 'filter by text' do
      I18n.default_locale = :en
      visit '/demo'
      fill_in 'Key word', with: 'Hello'
      click_link_or_button 'Go'

      expect(page).to have_content({by_text: 'Hello'}.to_json);
    end
  end
end

