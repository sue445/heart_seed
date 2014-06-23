module HeartSeed
  module DbSeed
    # delete all records and insert from seed yaml
    #
    # @param source_file [String]
    # @param model_class [Class] require. extends {ActiveRecord::Base}
    def self.bulk_insert(source_file: nil, model_class: nil)
      fixtures = HeartSeed::Converter.read_fixture_yml(source_file)
      models = fixtures.each_with_object([]) do |fixture, response|
        response << model_class.new(fixture)
        response
      end

      model_class.transaction do
        model_class.delete_all
        model_class.import(models)
      end
    end

    # import all seed yaml to table
    #
    # @param seed_dir [String]
    # @param tables   [Array<String>,String] table names array or comma separated table names. if empty, import all seed yaml. if not empty, import only these tables.
    def self.import_all(seed_dir: HeartSeed::Helper.seed_dir, tables: [])
      target_tables = parse_arg_tables(tables)

      ActiveRecord::Migration.verbose = true
      Dir.glob(File.join(seed_dir, "*.yml")) do |file|
        table_name = File.basename(file, '.*')
        next unless target_table?(table_name, target_tables)

        ActiveRecord::Migration.say_with_time("#{file} -> #{table_name}") do
          begin
            model_class = table_name.classify.constantize
            bulk_insert(source_file: file, model_class: model_class)
            ActiveRecord::Migration.say("[INFO] success", true)
          rescue => e
            ActiveRecord::Migration.say("[ERROR] #{e.message}", true)
          end
        end
      end
    end

    def self.parse_arg_tables(tables)
      return [] unless tables
      return tables if tables.class == Array

      tables.class == String ? tables.split(",") : []
    end

    private
    def self.target_table?(source_table, target_tables)
      return true if target_tables.empty?
      return target_tables.include?(source_table)
    end
  end
end
