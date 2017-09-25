module HeartSeed
  module DbSeed
    BULK = "bulk"
    ACTIVE_RECORD = "active_record"
    UPDATE = "update"

    # delete all records and bulk insert from seed yaml
    #
    # @param file_path [String]
    # @param model_class [Class] require. extends {ActiveRecord::Base}
    def self.bulk_insert(file_path: nil, model_class: nil, validate: true)
      fixtures = HeartSeed::Converter.read_fixture_yml(file_path)
      models = fixtures.each_with_object([]) do |fixture, response|
        response << model_class.new(fixture)
        response
      end

      model_class.transaction do
        model_class.delete_all
        model_class.import(models, validate: validate)
      end
    end

    # delete all records and insert from seed yaml
    #
    # @param file_path [String]
    # @param model_class [Class] require. extends {ActiveRecord::Base}
    def self.insert(file_path: nil, model_class: nil, validate: true)
      fixtures = HeartSeed::Converter.read_fixture_yml(file_path)
      model_class.transaction do
        model_class.delete_all
        fixtures.each do |fixture|
          model_class.new(fixture).save!(validate: validate)
        end
      end
    end

    # insert records. if same record exists, updated
    #
    # @param file_path [String]
    # @param model_class [Class] require. extends {ActiveRecord::Base}
    def self.insert_or_update(file_path: nil, model_class: nil, validate: true)
      fixtures = HeartSeed::Converter.read_fixture_yml(file_path)
      model_class.transaction do
        fixtures.each do |fixture|
          model = model_class.find_by(id: fixture["id"])
          if model
            model.attributes = fixture
            model.save!(validate: validate)
          else
            model_class.new(fixture).save!(validate: validate)
          end
        end
      end
    end

    # import all seed yaml to table
    #
    # @param seed_dir    [String]
    # @param tables      [Array<String>,String] table names array or comma separated table names.
    #                      if empty, import all seed yaml.
    #                      if not empty, import only these tables.
    # @param catalogs    [Array<String>,String] catalogs names array or comma separated catalog names.
    #                      if empty, import all seed yaml.
    #                      if not empty, import only these tables in catalogs.
    # @param insert_mode [String] const `ACTIVE_RECORD` or `UPDATE` other string.
    #                      if `ACTIVE_RECORD`, import with ActiveRecord. (`delete_all` and `create!`)
    #                      if `UPDATE`, import with ActiveRecord. (if exists same record, `update!`)
    #                      other, using bulk insert. (`delete_all` and BULK INSERT)
    def self.import_all(seed_dir: HeartSeed::Helper.seed_dir, tables: ENV["TABLES"], catalogs: ENV["CATALOGS"], mode: ENV["MODE"], validate: true)
      mode ||= BULK
      target_table_names = parse_target_table_names(tables: tables, catalogs: catalogs)

      raise "require TABLES or CATALOGS if production" if HeartSeed::Helper.production? && target_table_names.empty?

      ActiveRecord::Migration.verbose = true

      if target_table_names.empty?
        # seed all tables
        Dir.glob(File.join(seed_dir, "*.yml")) do |file_path|
          table_name = File.basename(file_path, '.*')

          ActiveRecord::Migration.say_with_time("#{file_path} -> #{table_name}") do
            insert_seed(file_path: file_path, table_name: table_name, mode: mode, validate: validate)
            ActiveRecord::Migration.say("[INFO] success", true)
          end
        end

      else
        # seed specified tables (follow the order)
        target_table_names.each do |table_name|
          file_path = File.join(seed_dir, "#{table_name}.yml")

          unless File.exists?(file_path)
            ActiveRecord::Migration.say("[WARN] #{file_path} is not exists")
            next
          end

          ActiveRecord::Migration.say_with_time("#{file_path} -> #{table_name}") do
            insert_seed(file_path: file_path, table_name: table_name, mode: mode, validate: validate)
            ActiveRecord::Migration.say("[INFO] success", true)
          end
        end
      end
    end

    # import all seed yaml to table with specified shards
    #
    # @param seed_dir    [String]
    # @param tables      [Array<String>,String] table names array or comma separated table names.
    #                      if empty, import all seed yaml.
    #                      if not empty, import only these tables.
    # @param catalogs    [Array<String>,String] catalogs names array or comma separated catalog names.
    #                      if empty, import all seed yaml.
    #                      if not empty, import only these tables in catalogs.
    # @param insert_mode [String] const `ACTIVE_RECORD` or `UPDATE` other string.
    #                      if `ACTIVE_RECORD`, import with ActiveRecord. (`delete_all` and `create!`)
    #                      if `UPDATE`, import with ActiveRecord. (if exists same record, `update!`)
    #                      other, using bulk insert. (`delete_all` and BULK INSERT)
    # @param shard_names [Array<String>]
    def self.import_all_with_shards(seed_dir: HeartSeed::Helper.seed_dir, tables: ENV["TABLES"], catalogs: ENV["CATALOGS"],
                                    mode: ENV["MODE"] || BULK, shard_names: [], validate: true)
      shard_names.each do |shard_name|
        ActiveRecord::Migration.say_with_time("import to shard: #{shard_name}") do
          ActiveRecord::Base.establish_connection(shard_name.to_sym)
          import_all(seed_dir: seed_dir, tables: tables, catalogs: catalogs, mode: mode, validate: validate)
        end
      end
    end

    def self.parse_target_table_names(tables: nil, catalogs: nil)
      # use tables in catalogs
      target_table_names = parse_arg_catalogs(catalogs)
      return target_table_names unless target_table_names.empty?

      # use tables
      parse_string_or_array_arg(tables)
    end
    private_class_method :parse_target_table_names

    def self.parse_string_or_array_arg(tables)
      return [] unless tables
      return tables if tables.class == Array

      tables.class == String ? tables.split(",") : []
    end

    def self.parse_arg_catalogs(catalogs)
      array_catalogs = parse_string_or_array_arg(catalogs)
      return [] if array_catalogs.empty?

      tables = []
      array_catalogs.each do |catalog|
        tables += HeartSeed::Helper.catalog_tables(catalog)
      end
      tables.compact
    end

    # insert yaml file to table
    # @param file_path  [String] source seed yaml file
    # @param table_name [String] output destination table
    # @param mode       [String] #{BULK}, #{UPDARE} or #{ACTIVE_RECORD}
    def self.insert_seed(file_path: nil, table_name: nil, mode: BULK, validate: true)
      model_class = table_name.classify.constantize
      case mode
      when ACTIVE_RECORD
        insert(file_path: file_path, model_class: model_class, validate: validate)
      when UPDATE
        insert_or_update(file_path: file_path, model_class: model_class, validate: validate)
      else
        # default is BULK mode
        bulk_insert(file_path: file_path, model_class: model_class, validate: validate)
      end
    end
    private_class_method :insert_seed
  end
end
