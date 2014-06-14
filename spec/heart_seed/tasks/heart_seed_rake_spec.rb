describe :heart_seed do
  include_context "uses temp dir"

  describe :init do
    include_context :rake_in_app_dir do
      let(:app_dir){ temp_dir }
    end

    subject!{ rake["heart_seed:init"].invoke }

    it { expect(Pathname("config/heart_seed.yml")).to be_exist }
    it { expect(Pathname("db/xls")).to be_exist }
    it { expect(Pathname("db/seeds")).to be_exist }
  end

  describe :xls do
    include_context :rake_in_app_dir

    before do
      allow_any_instance_of(Object).to receive(:seed_dir){ temp_dir }
    end

    after do
      ENV.delete("FILES")
    end

    context "When not exists ENV" do
      subject!{ rake["heart_seed:xls"].invoke }

      it { expect(Pathname.glob("#{temp_dir}/*")).to have(3).files }
      it { expect(Pathname("#{temp_dir}/articles.yml")).to be_exist }
      it { expect(Pathname("#{temp_dir}/comments.yml")).to be_exist }
      it { expect(Pathname("#{temp_dir}/likes.yml")).to be_exist }
    end

    context "When exists ENV['FILES']" do
      before do
        ENV["FILES"] = "articles.xls"
      end

      subject!{ rake["heart_seed:xls"].invoke }

      it { expect(Pathname.glob("#{temp_dir}/*")).to have(1).files }
      it { expect(Pathname("#{temp_dir}/articles.yml")).to be_exist }
      it { expect(Pathname("#{temp_dir}/comments.yml")).not_to be_exist }
      it { expect(Pathname("#{temp_dir}/likes.yml")).not_to be_exist }
    end
  end
end
