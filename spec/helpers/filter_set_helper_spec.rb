require 'rails_helper'

describe FilterSetHelper, type: :helper do
  before do
    helper.controller.prepend_view_path ['app/views/_filter_set/']
  end

  it 'test render' do
    expect(helper.test_render).to eq_in_slim %Q(
div
  | hello world
    )
  end
end

