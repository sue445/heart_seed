namespace :heart_seed do
  include HeartSeed::TaskHelper

  desc "create dir and file"
  task :init => ["config/heart_seed.yml", "db/xls", "db/seeds"] do
  end

  file "config/heart_seed.yml" => "config" do
    template = <<YAML
seed_dir: db/seeds
xls_dir: db/xls
YAML

    create_file("config/heart_seed.yml", template)
  end

  directory "config"
  directory "db/xls"
  directory "db/seeds"

  desc "create seed files by xls directory"
  task :xls do
    Dir.glob(File.join(xls_dir, "*.{xls,xlsx}")) do |file|
      next if File.basename(file) =~ /^~/

      puts "Source File: #{file}"
      sheets = HeartSeed::Converter.table_sheets(file)
      sheets.each do |sheet|
        unless ActiveRecord::Base.connection.table_exists?(sheet)
          puts "  [#{sheet}] Table is not found"
          next
        end

        dist_file = File.join(seed_dir, "#{sheet}.yml")
        fixtures = HeartSeed::Converter.convert_to_yml(source_file: file, source_sheet: sheet, dist_file: dist_file)
        if fixtures
          puts "  [#{sheet}] Create seed: #{dist_file}"
        else
          puts "  [#{sheet}] Sheet is empty"
        end
      end
    end
  end

  namespace :xls do
    desc "create seed files by xls file. e.g.) FILE=hoge.xlsx FILES=foo.xlsx,bar.xlsx"
    task :file do

    end

    desc "create seed file by xls sheet. e.g.) FILE=hoge.xlsx SHEET=foo"
    task :sheet do

    end
  end

  private
  def create_file(file, str)
    open(file, "w") do |out|
      out.write(str)
    end

    puts "create: #{file}"
  end
end
