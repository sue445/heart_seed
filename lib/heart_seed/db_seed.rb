module HeartSeed
  module DbSeed
    include HeartSeed::Helper

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

    def self.import_all(seed_dir: seed_dir, tables: [])
      Dir.glob(File.join(seed_dir, "*.yml")) do |file|
        table_name = File.basename(file, '.*')
        if target_table?(table_name, tables)
          model_class = table_name.classify.constantize
          bulk_insert(source_file: file, model_class: model_class)
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
