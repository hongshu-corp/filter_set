module FilterSet
  class Engine < ::Rails::Engine
    ActiveSupport.on_load :action_controller do
      helper FilterSet::Engine.helpers
    end
  end
end
