describe HeartSeed::DbSeed do
  describe "#bulk_insert" do
    subject{ HeartSeed::DbSeed.bulk_insert(source_file: source_file, model_class: model_class)  }

    let(:source_file){ "#{FIXTURE_DIR}/articles.yml" }
    let(:model_class){ Article }

    it{ expect{ subject }.to change(Article, :count).by(2) }
  end
end
