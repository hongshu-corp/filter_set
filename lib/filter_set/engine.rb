module FilterSet
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    initializer "FilterSetEngine.include_concern" do |app|
      ActionController::Base.send :include, ::FilterSetConcern
    end
  end
end
