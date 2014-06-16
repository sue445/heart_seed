module HeartSeed
  module Helper
    CONFIG_FILE = "config/heart_seed.yml"

    def self.config
      if File.exists?(CONFIG_FILE)
        YAML.load_file(CONFIG_FILE)
      else
        {
            "seed_dir" => "db/seeds",
            "xls_dir"  => "db/xls",
        }
      end
    end

    def self.seed_dir
      dir = config["seed_dir"] || "db/seeds"
      root_dir.join(dir)
    end

    def self.xls_dir
      dir = config["xls_dir"] || "db/xls"
      root_dir.join(dir)
    end

    def self.root_dir
      return @root_dir if @root_dir

      if defined? Rails
        Rails.root
      elsif defined? Padrino
        Pathname.new(Padrino.root)
      else
        Pathname.pwd
      end
    end

    def self.root_dir=(dir)
      @root_dir = Pathname.new(dir)
    end
  end
end
