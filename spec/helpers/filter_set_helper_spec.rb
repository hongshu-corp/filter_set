require 'rails_helper'

describe FilterSetHelper, type: :helper do
  let(:request_path) { '/some-path' }
  let(:request_path_with_args) { '/some-path?arg=hello&filter_conditions%5Btext%5D=' }
  let(:form_args) { [request_path, :get] }

  before do
    allow(helper).to receive(:request).and_return double('request', path: request_path, fullpath: request_path_with_args)
    allow(helper).to receive(:controller).and_return double('controller', { filter_conditions: OpenStruct.new })
    allow(helper).to receive(:stylesheet_link_tag).and_return ''
  end

  describe 'render search form' do
    it 'render an empty form with default args' do
      expect(helper.filter_set).to have_form(*form_args, with: {'class': 'filter-set'})
    end

    it 'render with form args' do
      expect(helper.filter_set method: 'post', class: 'my-form').to have_form(request_path, :post, with: {'class': 'my-form'})
    end

    it 'render with hidden field for save args' do
      expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
        with_tag 'input', with: {name: '__params', type: 'hidden', value: {arg: 'hello'}.to_json}
      end
    end

    describe 'should save __params in url avoid duplicated saved' do
      let(:request_path_with_args) { '/som-path?__params=%7B"arg"%3A"hello"%7D&condition%5Bby_text%5D=&submit=%7B"type"%3A"search"%7D' }

      specify do
        expect(helper.filter_set).to have_form(*form_args) do
          with_tag 'input', with: {name: '__params', type: 'hidden', value: {arg: 'hello'}.to_json}
        end
      end
    end
  end

  describe 'render text field' do
    context 'default key with no value' do
      subject do
        helper.filter_set do |fs|
          fs.by :text
        end
      end

      it 'render text field' do
        expect(subject).to have_form(*form_args) do
          with_tag 'input', with: {name: 'filter_conditions[text]', type: 'text', class: 'by-text'}
        end
      end

      it 'render text caption' do
        expect(helper).to receive(:t).with('filter_set.by.text').and_return('I18nText')

        expect(subject).to have_form(*form_args) do
          with_tag 'label', text: 'I18nText'
        end
      end
    end

    context 'new key' do
      let(:new_condition_key) { :new_cond }
      let(:new_text_key) { :new_text }
      it 'render text with new key' do
        expect(helper).to receive(:t).with("filter_set.by.#{new_text_key}", any_args).and_return('I18nText')

        expect(helper.filter_set do |fs|
          fs.by :text, key: new_text_key
        end).to have_form(*form_args) do
          with_tag 'label', text: 'I18nText'
        end
      end

      it 'render text with new key but default i18n' do
        expect(helper).to receive(:t).with("filter_set.by.#{new_text_key}", any_args).and_return(nil)
        expect(helper).to receive(:t).with('filter_set.by.text').and_return('I18nText')

        expect(helper.filter_set do |fs|
          fs.by :text, key: new_text_key
        end).to have_form(*form_args) do
          with_tag 'label', text: 'I18nText'
        end
      end

      it 'render text field by args in key, value and conditions name' do
        controller = double 'controller'
        allow(helper).to receive(:controller).and_return controller
        expect(controller).to receive(:filter_conditions).with(new_condition_key).and_return(OpenStruct.new new_text_key => 'hello')

        expect(helper.filter_set(key: new_condition_key) do |fs|
          fs.by :text, key: new_text_key, caption: 'KEY_WORD', placeholder: 'Key word'
        end).to have_form(*form_args) do
          with_tag 'label', text: 'KEY_WORD', with: {'class': "caption caption-text caption-#{new_text_key}"}
          with_tag 'input', with: {name: "#{new_condition_key}[#{new_text_key}]", type: 'text', value: 'hello', class: "by-text by-#{new_text_key}", placeholder: 'Key word'}
        end
      end
    end
  end

  describe 'render search submit' do
    it 'default search button' do
      expect(helper).to receive(:t).with('filter_set.submit.search.caption', _scope: '').and_return('I18nSearch')

      expect(helper.filter_set{|fs| fs.submit :search}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'submit', value: "#{{type: :search}.to_json}", class: 'submit submit-search'}, text: 'I18nSearch'
      end
    end

    it 'search with scope and default i18n' do
      expect(helper).to receive(:t).with('filter_set.submit.search.scopes.order', default: '').and_return('I18nOrder')
      expect(helper).to receive(:t).with('filter_set.submit.search.caption', _scope: 'I18nOrder').and_return('I18nSearchOrder')

      expect(helper.filter_set{|fs| fs.submit :search, scope: :order}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'submit', value: "#{{type: :search, scope: :order}.to_json}", class: 'submit submit-search submit-search-order'}, text: 'I18nSearchOrder'
      end
    end

    it 'search with scope and caption' do
      expect(helper.filter_set{|fs| fs.submit :search, scope: :order, caption: 'GO'}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'submit', value: "#{{type: :search, scope: :order}.to_json}", class: 'submit submit-search submit-search-order'}, text: 'GO'
      end
    end
  end

  describe 'render export' do
    it 'default export csv button' do
      expect(helper).to receive(:t).with('filter_set.submit.export.formats.csv', default: '').and_return('I18nCSV')
      expect(helper).to receive(:t).with('filter_set.submit.export.caption', _scope: '', _format: 'I18nCSV').and_return('I18nExport')

      expect(helper.filter_set{|fs| fs.submit :export}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'submit', value: "#{{type: :export, format: :csv}.to_json}", class: 'submit submit-export submit-export-csv'}, text: 'I18nExport'
      end
    end

    it 'export with args' do
      expect(helper).to receive(:t).with('filter_set.submit.export.formats.excel', default: '').and_return('I18nEXCEL')
      expect(helper).to receive(:t).with('filter_set.submit.export.scopes.pagging', default: '').and_return('I18nPaging')
      expect(helper).to receive(:t).with('filter_set.submit.export.caption', _scope: 'I18nPaging', _format: 'I18nEXCEL').and_return('I18nExport')

      expect(helper.filter_set{|fs| fs.submit :export, format: :excel, scope: 'pagging'}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'submit', value: "#{{type: :export, scope: 'pagging', format: :excel}.to_json}", class: 'submit submit-export submit-export-excel submit-export-pagging'}, text: 'I18nExport'
      end
    end
  end
end

