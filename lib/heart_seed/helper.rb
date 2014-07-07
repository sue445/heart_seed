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
            "catalogs" => {},
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

    # @return [Hash{String => Array<String>}] key: catalog name, value: table names
    def self.catalogs
      config["catalogs"] || {}
    end

    # @param catalog_name [String]
    # @return [Array<String>] table names in a specify catalog
    def self.catalog_tables(catalog_name)
      self.catalogs[catalog_name] || []
    end

    # @param default [String]
    # @return [String] {Rails.env}, PADRINO_ENV, RACK_ENV or default
    def self.environment(default="development")
      env ||= Rails.env          if defined? Rails
      env ||= ENV["PADRINO_ENV"] if ENV["PADRINO_ENV"]
      env ||= ENV["RACK_ENV"]    if ENV["RACK_ENV"]
      env ||= default
      env
    end

    def self.production?
      environment == "production"
    end
  end
end
