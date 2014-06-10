shared_context :rake_in_app_dir do
  let(:app_dir){ DUMMY_APP_DIR }

  before do
    RakeSharedContext.rake_dir = TASK_DIR
  end

  include_context "rake"

  around do |example|
    Dir.chdir(app_dir) do
      example.run
    end
  end
end
