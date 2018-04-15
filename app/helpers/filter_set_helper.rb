module FilterSetHelper
  class DefaultFilterBuilder
    def initialize builder, helper
      @builder = builder
      @helper = helper 
    end

    def by name, options={}
      key = options.delete :key
      caption = options.delete(:caption) || @helper.t("filter_set.captions.#{name}")
      filter_class = "by-#{name}"
      caption_class = "caption caption-#{name}"
      if key
        filter_class += " by-#{key}"
        caption_class += " caption-#{key}"
      end
      options[:class] = filter_class
      @helper.render "filter_set/#{name}", builder: self, key: (key||name), caption: caption, caption_class: caption_class, options: options
    end

    def caption text, clazz: nil
      @helper.render "filter_set/caption", text: text, clazz: clazz
    end

    def method_missing(m, *args, &block)
      @builder.send(m, *args, &block)
    end
  end

  def filter_set options={}, &block
    stylesheet_link_tag('filter_set/filter_set') +
    form_for(controller.filter_conditions(options[:key]), as: (options[:key]||:filter_conditions), url: request.path, html: {class: options[:class]||'filter-set'}, method: options[:method]||'get') do |f|
      block.call DefaultFilterBuilder.new(f, self) if block
    end
  end
end

