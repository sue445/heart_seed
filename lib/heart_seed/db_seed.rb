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
      tables ||= []
      if tables.class == String
        if tables.blank?
          target_tables = []
        else
          target_tables = tables.split(",")
        end
      else
        target_tables = tables
      end

      Dir.glob(File.join(seed_dir, "*.yml")) do |file|
        table_name = File.basename(file, '.*')
        next unless target_table?(table_name, target_tables)

        begin
          model_class = table_name.classify.constantize
          bulk_insert(source_file: file, model_class: model_class)
          puts "[INFO] #{file} -> #{table_name}"
        rescue => e
          puts "[ERROR] #{e.message}"
        end
      end
    end

    private
    def self.target_table?(source_table, target_tables)
      return true if target_tables.empty?
      return target_tables.include?(source_table)
    end
  end
end
