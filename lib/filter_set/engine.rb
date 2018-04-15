module FilterSet
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    initializer "filter_set.include_concern" do |app|
      ActionController::Base.send :include, ::FilterSetConcern
    end

    initializer "filter_set.assets.precompile" do |app|
      app.config.assets.precompile += %w(filter_set/filter_set.css)
    end
  end
end
