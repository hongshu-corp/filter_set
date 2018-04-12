require 'rails_helper'

describe FilterSetHelper, type: :helper do
  it 'test render' do
    expect(helper.test_render).to eq_in_slim %Q(
div
  | hello world
    )
  end
end

