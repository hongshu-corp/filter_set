require 'rails_helper'
require 'csv'

RSpec.describe DemoController, type: :controller do
  describe 'get conditions object in controller' do
    it 'set default empty objects' do
      DemoController.key = nil

      get :index

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new)
    end

    it 'get object by default key in params' do
      DemoController.key = nil

      get :index, {filter_conditions: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end

    it 'get object by search params' do
      DemoController.key = :my_conditions_key

      get :index, {my_conditions_key: {text: 'Hello'}}

      expect(assigns(:selected_conditions)).to eq (OpenStruct.new(text: 'Hello'))
    end
  end

  describe 'reconstruct params by __params' do
    specify do
      get :index, {__params: {arg: 'hello'}.to_json}

      expect(controller.params[:arg]).to eq 'hello'
    end
  end

  describe 'get submit type' do
    it 'action type with no scope' do
      get :index, {submit: {type: :search}.to_json}

      expect(assigns(:filter_action)).to eq (OpenStruct.new(type: 'search'))
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

    it 'export data' do
      allow(controller).to receive(:export_filename_pattern).and_return(filename)
      expect(controller).to receive(:send_data).with(csv.force_encoding('binary'), type: 'text/csv', filename: filename+'.csv')

      get :index, {submit: {type: :export, format: :csv}.to_json}
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

