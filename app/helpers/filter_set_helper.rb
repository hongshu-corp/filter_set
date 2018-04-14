module FilterSetHelper
  def test_render
    render 'filter_set/hello_world'
  end

  class DefaultFilterBuilder
    def initialize builder, helper
      @builder = builder
      @helper = helper 
    end

    def builder
      @builder
    end

    def by name, options={}
      filter_class = "filter-by-#{name}"
      filter_class += " filter-by-#{options[:key]}" if(options[:key])
      @helper.render "filter_set/#{name}", filter_builder: self, key: (options[:key]||name), clazz: filter_class, options: options
    end
  end

  def filter_set options={}, &block
    form_for(controller.filter_conditions(options[:key]), as: (options[:key]||:filter_conditions), url: request.path, html: {class: options[:class]||'filter-set'}, method: options[:method]||'get') do |f|
      block.call DefaultFilterBuilder.new(f, self) if block
    end
  end
end

