namespace :heart_seed do
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
    include HeartSeed::Helper

    Dir.glob(File.join(xls_dir, "*.{xls,xlsx}")) do |file|
      next if File.basename(file) =~ /^~/

      next unless target_file?(file)

      puts "Source File: #{file}"
      sheets = HeartSeed::Converter.table_sheets(file)
      sheets.each do |sheet|
        unless ActiveRecord::Base.connection.table_exists?(sheet)
          puts "  [#{sheet}] Table is not found"
          next
        end

        next unless target_sheet?(sheet)

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

  private
  def target_file?(file)
    return true if ENV["FILES"].blank?

    ENV["FILES"].split(",").include?(File.basename(file))
  end

  def target_sheet?(sheet)
    return true if ENV["SHEETS"].blank?

    ENV["SHEETS"].split(",").include?(sheet)
  end

  def create_file(file, str)
    open(file, "w") do |out|
      out.write(str)
    end

    puts "create: #{file}"
  end
end
