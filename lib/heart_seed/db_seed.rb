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
  end
end
