describe :heart_seed do
  include_context :rake_in_temp_dir

  describe :init do
    subject!{ rake["heart_seed:init"].invoke }

    it { expect(Pathname("config/heart_seed.yml")).to be_exist }
    it { expect(Pathname("db/xls")).to be_exist }
    it { expect(Pathname("db/seeds")).to be_exist }
  end
end
