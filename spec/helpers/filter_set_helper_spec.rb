require 'rails_helper'

describe FilterSetHelper, type: :helper do
  let(:request_path) { '/some-path' }

  before do
    allow(helper).to receive(:request).and_return double('request', path: request_path)
    allow(helper).to receive(:controller).and_return double('controller', { filter_conditions: OpenStruct.new })
  end

  describe 'render search form' do
    it 'render an empty form with default args' do
      expect(helper.filter_set).to have_form(request_path, :get, with: {'class': 'filter-set'})
    end

    it 'render with form args' do
      expect(helper.filter_set method: 'post', class: 'my-form').to have_form(request_path, :post, with: {'class': 'my-form'})
    end
  end

  describe 'render text field' do
    let(:form_args) { [request_path, :get] }

    it 'render text field by default key with no value' do
      expect(helper.filter_set do |fs|
        fs.by :text
      end).to have_form(*form_args) do
        with_tag 'input', with: {name: 'filter_conditions[text]', type: 'text', class: 'filter-by-text'}
      end
    end

    let(:new_condition_key) { :new_cond }
    let(:new_text_key) { :new_text }
    it 'render text field by args in key, value and conditions name' do
      controller = double 'controller'
      allow(helper).to receive(:controller).and_return controller
      expect(controller).to receive(:filter_conditions).with(new_condition_key).and_return(OpenStruct.new new_text_key => 'hello')

      expect(helper.filter_set(key: new_condition_key) do |fs|
        fs.by :text, key: new_text_key
      end).to have_form(*form_args) do
        with_tag 'input', with: {name: "#{new_condition_key}[#{new_text_key}]", type: 'text', value: 'hello', class: "filter-by-text filter-by-#{new_text_key}"}
      end
    end
  end
end

