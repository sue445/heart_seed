module HeartSeed
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "heart_seed/tasks/heart_seed.rake"
    end
  end
end
