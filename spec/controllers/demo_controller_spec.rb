require 'rails_helper'
require 'csv'

RSpec.describe DemoController, type: :controller do
  describe 'get conditions object in controller' do
    it 'set default empty objects' do
      DemoController.filter_key = nil

      get :index

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new)
    end

    it 'get object by default key in params' do
      DemoController.filter_key = nil

      get :index, {filter_conditions: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end

    it 'get object by search params' do
      DemoController.filter_key = :my_conditions_key

      get :index, {my_conditions_key: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end
  end

  describe 'get submit type' do
    it 'action type with no scope' do
      get :index, {filter_submit: {type: :search}.to_json}

      expect(assigns(:filter_action)).to eq (OpenStruct.new(type: 'search'))
    end
  end

  describe 'default skip pagging args' do
    it 'do not skip pagging params when no submit' do
      get :index, {page: 1}

      expect(assigns(:page)).to eq '1'
    end

    it 'skip pagging params when submit filter' do
      get :index, {page: 1, filter_submit: {type: :search}.to_json }

      expect(assigns(:page)).to eq nil
    end

    it 'keep page when submit current page' do
      get :index, {page: 1, filter_submit: {type: :search, paging: true}.to_json }

      expect(assigns(:page)).to eq '1'
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

