module HeartSeed
  class Railtie < ::Rails::Railtie
    rake_tasks do
      require "heart_seed/tasks"
    end
  end
end
