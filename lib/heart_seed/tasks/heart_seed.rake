namespace :heart_seed do
  desc "create dir and file"
  task :init => ["config/heart_seed.yml", "db/xls/.gitkeep", "db/seeds/.gitkeep"] do
    template = <<RUBY

# Appended by `rake heart_seed:init`
HeartSeed::DbSeed.import_all

RUBY

    append_file("db/seeds.rb", template)
  end

  file "config/heart_seed.yml" => "config" do
    template = <<YAML
seed_dir: db/seeds
xls_dir: db/xls
catalogs:
#  user:
#  - users
#  - user_profiles
YAML

    create_file("config/heart_seed.yml", template)
  end

  file "db/xls/.gitkeep" => "db/xls" do
    create_file("db/xls/.gitkeep")
  end

  file "db/seeds/.gitkeep" => "db/seeds" do
    create_file("db/seeds/.gitkeep")
  end

  directory "config"
  directory "db/xls"
  directory "db/seeds"

  desc "create seed files by xls directory (options: FILES=table1.xls,table2.xlsx SHEETS=sheet1,sheet2)"
  task :xls => :environment do
    ActiveRecord::Migration.verbose = true
    Dir.glob(File.join(HeartSeed::Helper.xls_dir, "*.{xls,xlsx}")) do |file|
      next if File.basename(file) =~ /^~/

      next unless target_file?(file)

      ActiveRecord::Migration.say_with_time("Source File: #{file}") do
        sheets = HeartSeed::Converter.table_sheets(file)
        sheets.each do |sheet|
          unless ActiveRecord::Base.connection.table_exists?(sheet)
            ActiveRecord::Migration.say("[#{sheet}] Table is not found", true)
            next
          end

          next unless target_sheet?(sheet)

          dist_file = File.join(HeartSeed::Helper.seed_dir, "#{sheet}.yml")
          fixtures = HeartSeed::Converter.convert_to_yml(source_file: file, source_sheet: sheet, dist_file: dist_file)
          if fixtures
            ActiveRecord::Migration.say("[#{sheet}] Create seed: #{dist_file}", true)
          else
            ActiveRecord::Migration.say("  [#{sheet}] Sheet is empty", true)
          end
        end
      end
    end
  end

  namespace :db do
    desc "Load the seed data from db/seeds/*.yml (options: TABLES=table1,table2 CATALOGS=catalog1,catalog2)"
    task :seed => :environment do
      HeartSeed::DbSeed.import_all
    end
  end

  private
  def target_file?(file)
    return true if ENV["FILES"].blank?

    ENV["FILES"].split(",").include?(File.basename(file))
  end

  def target_sheet?(sheet)
    return true if ENV["SHEETS"].blank?

    ENV["SHEETS"].split(",").include?(sheet)
  end

  def create_file(file, str = nil)
    open(file, "w") do |out|
      out.write(str) if str
    end

    puts "create: #{file}"
  end

  def append_file(file, str)
    if File.exists?(file)
      return if File.open(file).read.include?(str)
    end

    File.open(file, "a") do |out|
      out.write(str)
    end

    puts "append: #{file}"
  end
end
