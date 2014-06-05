shared_context :rake_in_temp_dir do
  before do
    RakeSharedContext.rake_dir = TASK_DIR
  end

  include_context "rake"

  include_context :uses_temp_dir do
    around do |example|
      Dir.chdir(temp_dir) do
        example.run
      end
    end
  end
end
