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
articles_1:
  id: 1
  title: title1
  description: description1
  created_at: '2014-06-01 12:10:00 +0900'
articles_2:
  id: 2
  title: title2
  description: description2
  created_at: '2014-06-02 12:10:00 +0900'
YAML
      end

      its(["articles_1"]){ should == {"id" => 1, "title" => "title1", "description" => "description1", "created_at" => "2014-06-01 12:10:00 +0900"} }
      its(["articles_2"]){ should == {"id" => 2, "title" => "title2", "description" => "description2", "created_at" => "2014-06-02 12:10:00 +0900"} }
    end

  end

  describe "#read_fixture_yml" do
    subject{ HeartSeed::Converter.read_fixture_yml(source_file) }

    let(:source_file){ "#{FIXTURE_DIR}/articles.yml" }

    its(:count){ should == 2 }
    its([0]){ should == {"id" => 1, "title" => "title1", "description" => "description1", "created_at" => "2014-06-01 12:10:00 +0900"} }
    its([1]){ should == {"id" => 2, "title" => "title2", "description" => "description2", "created_at" => "2014-06-02 12:10:00 +0900"} }
  end

  describe "#table_sheets" do
    subject{ HeartSeed::Converter.table_sheets(source_file) }

    let(:source_file) { "#{DATA_DIR}/articles.xls" }

    it{ should == ["articles", "Sheet2"] }
  end
end
