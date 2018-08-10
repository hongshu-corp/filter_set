require 'rack'
require 'uri'

module FilterSetHelper
  class DefaultFilterBuilder
    def initialize builder, helper, main_key
      @builder = builder
      @helper = helper 
      @main_key = main_key
    end

    def builder
      @builder
    end

    def main_key
      @main_key
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
      options[:class] = (options[:class] ? options[:class]+' ' : '') +  filter_class
      @helper.render "filter_set/by/#{filter}", builder: self, key: (key||filter), caption: caption, caption_class: caption_class, options: options
    end

    def caption text, clazz: nil
      @helper.render "filter_set/caption", text: text, clazz: clazz
    end

    def submit type, options={}
      options[:name] = Rails.configuration.filter_set_submit
      options[:type] = 'submit'
      options[:_class] = "submit submit-#{type}"
      scope = options.delete :scope
      caption = options.delete :caption
      submit_value = {type: type}
      i18n_scope = ''
      if scope
        i18n_scope = @helper.t("filter_set.submit.#{type}.scopes.#{scope}", default: '')
        submit_value.merge! scope: scope
        options[:_class] += " submit-#{type}-#{scope}"
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
      i18n_paging = if options.delete(:paging).to_s.downcase == 'true'
                      submit_value.merge! paging: true
                      @helper.t("filter_set.submit.export.paging", default: '')
                    end.to_s

      options[:_class] += " submit-#{type}-#{format}"
      submit_render type, submit_value, options do
        caption || @helper.t("filter_set.submit.#{type}.caption", _scope: i18n_scope, _format: i18n_format, _paging: i18n_paging)
      end
    end

    protected

    def method_missing(m, *args, &block)
      @builder.send(m, *args, &block)
    end

    def submit_render type, submit_value, options={}
      options[:value] = submit_value.to_json
      default_class = options.delete :_class
      options[:class] ||= default_class
      @helper.render layout: "filter_set/submit/#{type}", locals: {options: options} do
        yield.html_safe
      end
    end
  end

  def filter_set options={}, &block
    object = controller.filter_conditions(options[:key])
    main_key = options[:key]||Rails.configuration.filter_set_key
    query_params = Rack::Utils.parse_nested_query(URI.parse(request.fullpath).query)
    query_params.delete main_key.to_s
    query_params.delete Rails.configuration.filter_set_submit.to_s
    Rails.configuration.filter_set_page_params.each do |k|
      query_params.delete "__#{k}"
    end
    page_params = Rails.configuration.filter_set_page_params.map(&:to_s).map {|k| [k, query_params.delete(k)]}
    stylesheet_link_tag('filter_set/filter_set') +
      form_for(object, as: main_key, url: request.path, enforce_utf8: false, html: {'class': options[:class]||'filter-set'}, method: options[:method]||'get') do |f|
      page_params.each do |k, v|
        if v.present?
          concat(key_value_to_hidden "__#{k}", v)
        end
      end
      concat(key_value_to_hidden('', query_params)) if query_params.size > 0
      concat(capture(DefaultFilterBuilder.new(f, self, main_key), &block)) if block
    end
  end

  private

  def key_value_to_hidden key, value
    if(value.is_a? Hash)
      hash_to_hidden key, value
    elsif(value.is_a? Array)
      array_to_hidden key, value
    else
      hidden_field_tag(key, value)
    end
  end

  def array_to_hidden key, array
    array.map do |v|
      key_value_to_hidden "#{key}[]", v
    end.sum
  end

  def hash_to_hidden key, hash
    hash.map do |k, v|
      key_value_to_hidden build_key(key, k), v
    end.sum
  end

  def build_key key, sub_key
    key.blank? ? sub_key : "#{key}[#{sub_key}]"
  end
end

