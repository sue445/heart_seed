describe HeartSeed::Converter do
  describe "#convert_to_yml" do
    subject{ HeartSeed::Converter.convert_to_yml(source_file: source_file, source_sheet: source_sheet, dist_file: dist_file) }

    where(:format) do
      [
          ["xls"],
          ["xlsx"],
      ]
    end

    with_them do
      let(:source_file) { "#{DATA_DIR}/articles.#{format}" }
      let(:source_sheet){ "articles" }
      let(:dist_file)   { "#{temp_dir}/articles.yml" }

      include_context :uses_temp_dir

      it "should create yaml" do
        subject
        expect(File.read(dist_file)).to eq <<YAML
---
- id: 1
  title: title1
  description: description1
  created_at: '2014-06-01 12:10:00 +0900'
- id: 2
  title: title2
  description: description2
  created_at: '2014-06-02 12:10:00 +0900'
YAML
      end

      its([0]){ should == {"id" => 1, "title" => "title1", "description" => "description1", "created_at" => "2014-06-01 12:10:00 +0900"} }
      its([1]){ should == {"id" => 2, "title" => "title2", "description" => "description2", "created_at" => "2014-06-02 12:10:00 +0900"} }
    end

  end
end
