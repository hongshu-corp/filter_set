module FilterSet
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    initializer "filter_set.init" do |app|
      ActionController::Base.send :include, ::FilterSetConcern
      app.config.assets.precompile += %w(filter_set/filter_set.css)
      app.config.i18n.load_path += Dir[Engine.root.join('config', 'locales','**', '*.{rb,yml}').to_s]
      app.config.i18n.default_locale = :"zh-CN"
    end
  end
end
