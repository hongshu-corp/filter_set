module FilterSetHelper
  class DefaultFilterBuilder
    def initialize builder, helper
      @builder = builder
      @helper = helper 
    end

    def by filter, options={}
      key = options.delete :key
      filter_class = "by-#{filter}"
      caption_class = "caption caption-#{filter}"
      caption = options.delete(:caption)
      if key
        filter_class += " by-#{key}"
        caption_class += " caption-#{key}"
        caption ||= @helper.t("filter_set.captions.#{key}", default: nil)
      end
      caption ||= @helper.t("filter_set.captions.#{filter}")
      options[:class] = filter_class
      @helper.render "filter_set/by/#{filter}", builder: self, key: (key||filter), caption: caption, caption_class: caption_class, options: options
    end

    def caption text, clazz: nil
      @helper.render "filter_set/caption", text: text, clazz: clazz
    end

    def submit type, options={}
      options[:name] = 'submit'
      options[:type] = 'submit'
      options[:class] = "submit submit-#{type}"
      submit_value = {type: type}
      scope = options.delete :scope
      caption = options.delete :caption
      if scope
        submit_value.merge! scope: scope
        caption ||= @helper.t("filter_set.submits.search.#{scope}", default: nil)
        options[:class] += " submit-#{type}-#{scope}"
      end
      options[:value] = submit_value.to_json
      @helper.render layout: "filter_set/submit/#{type}", locals: {options: options} do
        (caption || @helper.t('filter_set.submits.search')).html_safe
      end
    end

    def method_missing(m, *args, &block)
      @builder.send(m, *args, &block)
    end
  end

  def filter_set options={}, &block
    stylesheet_link_tag('filter_set/filter_set') +
    form_for(controller.filter_conditions(options[:key]), as: (options[:key]||:filter_conditions), url: request.path, html: {'class': options[:class]||'filter-set'}, method: options[:method]||'get') do |f|
      block.call DefaultFilterBuilder.new(f, self) if block
    end
  end
end

