shared_context :uses_temp_dir do
  let!(:temp_dir){ Dir.mktmpdir("rspec-") }

  after do
    FileUtils.rm_rf(temp_dir)
  end
end
