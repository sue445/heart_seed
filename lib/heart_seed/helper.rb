module HeartSeed
  module Helper
    CONFIG_FILE = "config/heart_seed.yml"

    # read config/heart_seed.yml
    # @return [Hash{String => String}]
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

    # @return [Pathname]
    def self.seed_dir
      dir = config["seed_dir"] || "db/seeds"
      root_dir.join(dir)
    end

    # @return [Pathname]
    def self.xls_dir
      dir = config["xls_dir"] || "db/xls"
      root_dir.join(dir)
    end

    # return {Rails.root} , {Padrino.root} or current dir
    # @return [Pathname]
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

    # @param dir [String]
    def self.root_dir=(dir)
      @root_dir = Pathname.new(dir)
    end
  end
end
