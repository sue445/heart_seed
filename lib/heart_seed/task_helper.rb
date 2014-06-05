module HeartSeed
  module TaskHelper
    CONFIG_FILE = "config/heart_seed.yml"

    def config
      if File.exists?(CONFIG_FILE)
        YAML.load_file(CONFIG_FILE)
      else
        {
            "seed_dir" => "db/seeds",
            "xls_dir"  => "db/xls",
        }
      end
    end

    def seed_dir
      dir = config["seed_dir"] || "db/seeds"
      root_dir.join(dir)
    end

    def xls_dir
      dir = config["xls_dir"] || "db/xls"
      root_dir.join(dir)
    end

    def root_dir
      return @root_dir if @root_dir

      if defined? Rails
        Rails.root
      elsif defined? Padrino
        Pathname.new(Padrino.root)
      else
        Pathname.pwd
      end
    end

    def root_dir=(dir)
      @root_dir = Pathname.new(dir)
    end
  end
end
