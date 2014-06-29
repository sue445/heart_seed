SHARD_NAMES = %w(test shard_test)
MAIN_SHARD = "test"

SHARD_NAMES.each do |shard_name|
  db_file = File.join(__dir__, "#{shard_name}.sqlite3")
  FileUtils.rm(db_file) if File.exists?(db_file)

  ActiveRecord::Base.configurations[shard_name] = {
      adapter:  "sqlite3",
      # database: ":memory:",
      database: db_file,
      timeout:  500
  }

  DatabaseRewinder.create_cleaner(shard_name)
  ActiveRecord::Base.establish_connection(shard_name.to_sym)

  load File.join(__dir__, "migration.rb")
end

ActiveRecord::Base.establish_connection(MAIN_SHARD.to_sym)

def clean_all_shards
  SHARD_NAMES.each do |shard_name|
    ActiveRecord::Base.establish_connection(shard_name.to_sym)
    DatabaseRewinder.clean_all
  end
  ActiveRecord::Base.establish_connection(MAIN_SHARD.to_sym)
end
