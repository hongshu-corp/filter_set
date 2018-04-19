require 'rack'
require 'uri'

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
        caption ||= @helper.t("filter_set.by.#{key}", default: nil)
      end
      caption ||= @helper.t("filter_set.by.#{filter}")
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
      scope = options.delete :scope
      caption = options.delete :caption
      submit_value = {type: type}
      i18n_scope = ''
      if scope
        i18n_scope = @helper.t("filter_set.submit.#{type}.scopes.#{scope}", default: '')
        submit_value.merge! scope: scope
        options[:class] += " submit-#{type}-#{scope}"
      end
      send("submit_#{type}", type, submit_value, i18n_scope, caption, options)
    end

    def submit_search type, submit_value, i18n_scope, caption, options={}
      submit_render type, submit_value, options do
        caption || @helper.t("filter_set.submit.#{type}.caption", _scope: i18n_scope)
      end
    end

    def submit_export type, submit_value, i18n_scope, caption, options={}
      format = options.delete(:format) || :csv
      submit_value.merge! format: format
      i18n_format = @helper.t("filter_set.submit.export.formats.#{format}", default: '')
      options[:class] += " submit-#{type}-#{format}"
      submit_render type, submit_value, options do
        caption || @helper.t("filter_set.submit.#{type}.caption", _scope: i18n_scope, _format: i18n_format)
      end
    end

    protected

    def method_missing(m, *args, &block)
      @builder.send(m, *args, &block)
    end

    def submit_render type, submit_value, options={}
      options[:value] = submit_value.to_json
      @helper.render layout: "filter_set/submit/#{type}", locals: {options: options} do
        yield.html_safe
      end
    end
  end

  def filter_set options={}, &block
    object = controller.filter_conditions(options[:key])
    main_key = options[:key]||Rails.configuration.filter_set_key
    query_params = Rack::Utils.parse_nested_query(URI.parse(request.fullpath).query)
    last_query_params = query_params['__params']
    if last_query_params
      query_params = last_query_params
    else
      query_params.delete main_key.to_s
      query_params = query_params.to_json
    end
    stylesheet_link_tag('filter_set/filter_set') +
    form_for(object, as: main_key, url: request.path, html: {'class': options[:class]||'filter-set'}, method: options[:method]||'get') do |f|
      hidden_field_tag('__params', query_params) + (block ? capture(DefaultFilterBuilder.new(f, self), &block) : '')
    end
  end
end

