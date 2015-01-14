describe HeartSeed::DbSeed do
  describe "#bulk_insert" do
    subject{ HeartSeed::DbSeed.bulk_insert(source_file: source_file, model_class: model_class) }

    let(:source_file){ "#{FIXTURE_DIR}/articles.yml" }
    let(:model_class){ Article }

    it{ expect{ subject }.to change(Article, :count).by(2) }
  end

  describe "#insert" do
    subject { HeartSeed::DbSeed.insert(source_file: source_file, model_class: model_class) }

    let(:source_file) { "#{FIXTURE_DIR}/comments.yml" }
    let(:model_class) { Comment }

    it{ expect{ subject }.to change(Comment, :count).by(2) }
  end

  describe "#import_all" do
    subject{ HeartSeed::DbSeed.import_all(seed_dir: seed_dir, tables: tables, catalogs: catalogs, insert_mode: insert_mode) }

    let(:seed_dir)   { FIXTURE_DIR }
    let(:tables)     { [] }
    let(:catalogs)   { [] }
    let(:insert_mode){}

    before do
      # FIXME can not clear if using `DatabaseRewinder.clean`
      DatabaseRewinder.clean_all
    end

    after do
      # FIXME can not clear if using `DatabaseRewinder.clean`
      DatabaseRewinder.clean_all
    end

    context "When empty tables" do
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

    context "When specify catalogs" do
      let(:catalogs){ ["article"] }

      before do
        allow(HeartSeed::Helper).to receive(:catalogs){
          { "article" => ["articles", "likes"] }
        }
      end

      it{ expect{ subject }.to change(Article, :count).by(2) }
      it{ expect{ subject }.to change(Comment, :count).by(0) }
      it{ expect{ subject }.to change(Like   , :count).by(1) }
    end

    context "When specify insert_mode" do
      let(:insert_mode) { HeartSeed::DbSeed::ACTIVE_RECORD }

      it{ expect{ subject }.to change(Article, :count).by(2) }
      it{ expect{ subject }.to change(Comment, :count).by(2) }
      it{ expect{ subject }.to change(Like   , :count).by(1) }
    end
  end

  describe "#import_all_with_shards" do
    subject do
      HeartSeed::DbSeed.import_all_with_shards(
          seed_dir:    seed_dir,
          tables:      tables,
          catalogs:    catalogs,
          shard_names: shard_names
      )
    end

    let(:seed_dir)   { FIXTURE_DIR }
    let(:tables)     { [] }
    let(:catalogs)   { [] }
    let(:shard_names){ %w(test shard_test) }

    around do |example|
      # FIXME for travis unstable test
      # https://github.com/sue445/heart_seed/issues/11
      clean_all_shards

      example.run

      clean_all_shards
    end

    it{ expect{ subject }.to change(Article     , :count).from(0).to(2) }
    it{ expect{ subject }.to change(Comment     , :count).from(0).to(2) }
    it{ expect{ subject }.to change(Like        , :count).from(0).to(1) }
    it{ expect{ subject }.to change(ShardArticle, :count).from(0).to(1) }
  end

  describe "#parse_string_or_array_arg" do
    subject{ HeartSeed::DbSeed.parse_string_or_array_arg(tables) }

    where(:tables, :expected) do
      [
          [nil                   , []],
          [""                    , []],
          [%w(articles comments) , %w(articles comments)],
          ["articles,comments"   , %w(articles comments)],
      ]
    end

    with_them do
      it{ should eq expected }
    end
  end

  describe "#parse_arg_catalogs" do
    subject{ HeartSeed::DbSeed.parse_arg_catalogs(catalogs) }

    before do
      allow(HeartSeed::Helper).to receive(:catalogs){
        {
            "article" => ["articles", "likes"],
            "user"    => ["users", "user_profiles"],
        }
      }
    end

    where(:catalogs, :expected) do
      [
          [nil              , []],
          [""               , []],
          ["article"        , %w(articles likes)],
          ["article,user"   , %w(articles likes users user_profiles)],
          [%w(article)      , %w(articles likes)],
          [%w(article user) , %w(articles likes users user_profiles)],
      ]
    end

    with_them do
      it{ should eq expected }
    end
  end
end
