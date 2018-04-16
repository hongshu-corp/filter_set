require 'rails_helper'

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

  describe 'get submit type' do
    it 'action type with no scope' do
      get :index, {submit: {type: :search}.to_json}

      expect(assigns(:filter_action)).to eq (OpenStruct.new(type: 'search'))
    end
  end

  context 'e2e' do
    render_views

    it 'filter by text' do
      visit '/demo'
      fill_in 'Key word', with: 'Hello'
      click_link_or_button 'Go'

      expect(page).to have_content({by_text: 'Hello'}.to_json);
    end
  end
end
