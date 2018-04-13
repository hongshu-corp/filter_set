require 'rails_helper'

RSpec.describe DemoController, type: :controller do
  context 'e2e' do
    it 'filter by text' do
      visit '/demo'
      fill_in 'Key word', with: 'Hello'
      click_link_or_button 'Search'
    end
  end
end
