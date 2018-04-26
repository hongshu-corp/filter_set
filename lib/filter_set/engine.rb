module FilterSet
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    initializer "filter_set.init" do |app|
      ActionController::Base.send :prepend, ::FilterSetConcern
      app.config.assets.precompile += %w(filter_set/filter_set.css)
      app.config.i18n.load_path += Dir[Engine.root.join('config', 'locales','**', '*.{rb,yml}').to_s]
      app.config.i18n.default_locale = :"zh-CN"

      app.config.filter_set_key = :filter_conditions
      app.config.filter_set_submit = :filter_submit
      app.config.filter_set_page_params = [:page, :per_page]
    end
  end
end
