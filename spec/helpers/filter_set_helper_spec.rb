require 'rails_helper'

describe FilterSetHelper, type: :helper do
  let(:request_path) { '/some-path' }
  let(:form_args) { [request_path, :get] }
  let(:request_path_with_args) { '/some-path?arg=hello&filter_conditions%5Btext%5D=' }

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
  end

  describe 'render other params' do
    let(:args) { {arg: 'hello'} }
    let(:request_path_with_args) { '/some-path?' + args.to_query }

    it 'render with hidden field for save args simple args' do
      expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
        with_tag 'input', with: {name: 'arg', type: 'hidden', value: 'hello'}
      end
    end

    describe 'render with hidden field for save nested hash args' do
      let(:args) { {arg: {word: 'hello'}} }
      specify do
        expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
          with_tag 'input', with: {name: 'arg[word]', type: 'hidden', value: 'hello'}
        end
      end
    end

    describe 'render with hidden field for save args array args' do
      let(:args) { {arg: ['hello', 'world']} }
      specify do
        expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
          with_tag 'input', with: {name: 'arg[]', type: 'hidden', value: 'hello'}
          with_tag 'input', with: {name: 'arg[]', type: 'hidden', value: 'world'}
        end
      end
    end

    #describe 'render with hidden field for save nested array args' do
      #let(:args) { {arg: [['hello']]} }
      #specify do
        #expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
          #with_tag 'input', with: {name: 'arg[][]', type: 'hidden', value: 'hello'}
        #end
      #end
    #end

    describe 'render with hidden field for save args hash args' do
      let(:args) { {arg: {a: 1, b: 2}} }
      specify do
        expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
          with_tag 'input', with: {name: 'arg[a]', type: 'hidden', value: '1'}
          with_tag 'input', with: {name: 'arg[b]', type: 'hidden', value: '2'}
        end
      end
    end

    describe 'do not save paging args' do
      let(:args) { {page: 1, per_page: 30} }
      specify do
        expect(helper.filter_set {|f| f.by :text}).to have_form(*form_args) do
          without_tag 'input', with: {name: 'page', type: 'hidden', value: '1'}
          without_tag 'input', with: {name: 'per_page', type: 'hidden', value: '30'}
          with_tag 'input', with: {name: '__page', type: 'hidden', value: '1'}
          with_tag 'input', with: {name: '__per_page', type: 'hidden', value: '30'}
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
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :search}.to_json}", class: 'submit submit-search'}, text: 'I18nSearch'
      end
    end

    it 'search with scope and default i18n' do
      expect(helper).to receive(:t).with('filter_set.submit.search.scopes.order', default: '').and_return('I18nOrder')
      expect(helper).to receive(:t).with('filter_set.submit.search.caption', _scope: 'I18nOrder').and_return('I18nSearchOrder')

      expect(helper.filter_set{|fs| fs.submit :search, scope: :order}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :search, scope: :order}.to_json}", class: 'submit submit-search submit-search-order'}, text: 'I18nSearchOrder'
      end
    end

    it 'search with scope and caption' do
      expect(helper.filter_set{|fs| fs.submit :search, scope: :order, caption: 'GO'}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :search, scope: :order}.to_json}", class: 'submit submit-search submit-search-order'}, text: 'GO'
      end
    end
  end

  describe 'render export' do
    it 'default export csv button' do
      expect(helper).to receive(:t).with('filter_set.submit.export.formats.csv', default: '').and_return('I18nCSV')
      expect(helper).to receive(:t).with('filter_set.submit.export.caption', _scope: '', _format: 'I18nCSV', _paging: '').and_return('I18nExport')

      expect(helper.filter_set{|fs| fs.submit :export}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :export, format: :csv}.to_json}", class: 'submit submit-export submit-export-csv'}, text: 'I18nExport'
      end
    end

    it 'export with args' do
      expect(helper).to receive(:t).with('filter_set.submit.export.formats.excel', default: '').and_return('I18nEXCEL')
      expect(helper).to receive(:t).with('filter_set.submit.export.scopes.order', default: '').and_return('I18nOrder')
      expect(helper).to receive(:t).with('filter_set.submit.export.caption', _scope: 'I18nOrder', _format: 'I18nEXCEL', _paging: '').and_return('I18nExport')

      expect(helper.filter_set{|fs| fs.submit :export, format: :excel, scope: 'order'}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :export, scope: 'order', format: :excel}.to_json}", class: 'submit submit-export submit-export-excel submit-export-order'}, text: 'I18nExport'
      end
    end

    it 'export with current page' do
      expect(helper).to receive(:t).with('filter_set.submit.export.formats.csv', default: '').and_return('I18nCSV')
      expect(helper).to receive(:t).with('filter_set.submit.export.paging', default: '').and_return('I18nPaging')
      expect(helper).to receive(:t).with('filter_set.submit.export.caption', _scope: '', _format: 'I18nCSV', _paging: 'I18nPaging').and_return('I18nExport')

      expect(helper.filter_set{|fs| fs.submit :export, paging: true}).to have_form(*form_args) do
        with_tag 'button', with: {type: 'submit', name: 'filter_submit', value: "#{{type: :export, format: :csv, paging: true}.to_json}", class: 'submit submit-export submit-export-csv'}, text: 'I18nExport'
      end
    end
  end
end

