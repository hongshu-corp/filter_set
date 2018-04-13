module FilterSetHelper
  def test_render
    render 'filter_set/hello_world'
  end

  def filter_set options={}, &block
    content_tag :form, 'accept-charset': options[:'action-charset']||'UTF-8',
      action: request.path, class: options[:class]||'filter-set', method: options[:method]||'get' do
      block.call if block
    end
    form_for('', model_name: 'hello', url: '') do |f|
    end
  end
end
