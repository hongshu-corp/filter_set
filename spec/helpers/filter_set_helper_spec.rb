require 'rails_helper'

describe FilterSetHelper, type: :helper do
  it 'test render' do
    expect(helper.test_render).to eq_in_slim %Q(
div hello world
    )
  end

  describe 'render search form' do
    let(:request_path) { '/some-path' }

    before do
      allow(helper).to receive(:request).and_return double('request', path: request_path)
    end

    it 'render an empty form with default args' do
      expect(helper.filter_set).to eq_in_slim %Q(
form.filter-set action='#{request_path}' accept-charset='UTF-8' method='get'
      )
    end

    it 'render with form args' do
      expect(helper.filter_set 'action-charset': 'gbk', method: 'post', class: 'my-form').to eq_in_slim %Q(
form.my-form action='#{request_path}' accept-charset='gbk' method='post'
      )
    end
  end
end

