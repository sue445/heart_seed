describe HeartSeed::DbSeed do
  describe "#bulk_insert" do
    subject{ HeartSeed::DbSeed.bulk_insert(source_file: source_file, model_class: model_class)  }

    let(:source_file){ "#{FIXTURE_DIR}/articles.yml" }
    let(:model_class){ Article }

    it{ expect{ subject }.to change(Article, :count).by(2) }
  end

  describe "#import_all" do
    subject{ HeartSeed::DbSeed.import_all(seed_dir: seed_dir, tables: tables)  }

    let(:seed_dir){ FIXTURE_DIR }

    context "When empty tables" do
      let(:tables)  { [] }

      it{ expect{ subject }.to change(Article, :count).by(2) }
      it{ expect{ subject }.to change(Comment, :count).by(2) }
      it{ expect{ subject }.to change(Like   , :count).by(1) }
    end

    context "When specify tables" do
      let(:tables)  { ["articles"] }

      it{ expect{ subject }.to change(Article, :count).by(2) }
      it{ expect{ subject }.to change(Comment, :count).by(0) }
      it{ expect{ subject }.to change(Like   , :count).by(0) }
    end
  end
end
