module HeartSeed
  module Converter
    HEADER_ROW = 1

    # convert xls,xlsx to yaml and write to file.
    #
    # ## example
    # ### source xls
    # ```csv
    # id, title, description, created_at
    # 1, title1, description1, 2014-06-01 12:10:00 +0900
    # 2, title2, description2, 2014-06-02 12:10:00 +0900
    # ```
    #
    # ### output yaml
    # ```yaml
    # ---
    # articles_1:
    #   id: 1
    #   title: title1
    #   description: description1
    #   created_at: '2014-06-01 12:10:00 +0900'
    # articles_2:
    #   id: 2
    #   title: title2
    #   description: description2
    #   created_at: '2014-06-02 12:10:00 +0900'
    # ```
    #
    # @param source_file  [String] source file (xls, xlsx)
    # @param source_sheet [String]
    # @param dist_file    [String] don't write to file if blank
    #
    # @return [Array<Hash>]
    def self.convert_to_yml(source_file: nil, source_sheet: nil, dist_file: nil)
      sheet =
          case File.extname(source_file)
          when ".xls"
            Roo::Excel.new(source_file).sheet(source_sheet)
          when ".xlsx"
            Roo::Excelx.new(source_file).sheet(source_sheet)
          else
            raise ArgumentError, "unknown format: #{source_file}"
          end

      fixtures = read_sheet(sheet, source_sheet)

      unless dist_file.blank?
        File.open(dist_file, "w") do |f|
          f.write(YAML.dump(fixtures))
        end
      end

      fixtures
    end

    private
    def self.read_sheet(sheet, name)
      header_keys = sheet.row(HEADER_ROW)
      fixtures = {}

      (HEADER_ROW + 1 .. sheet.last_row).each do |row_num|
        row_value = {}
        header_keys.each_with_index do |key, col_index|
          value = sheet.cell(row_num, col_index + 1)

          case sheet.celltype(row_num, col_index + 1)
          when :float
            # ex) 1.0 -> 1
            value = value.to_i if value == value.to_i
          when :date, :time, :datetime
            # value is DateTime and localtime, but not included TimeZone(UTC)
            time = Time.zone.at(value.to_i - Time.zone.utc_offset)
            value = time.to_s
          end

          row_value[key] = value
        end

        suffix = row_value.has_key?("id") ? row_value["id"] : row_num - 1
        row_name = "#{name}_#{suffix}"

        fixtures[row_name] = row_value
      end

      fixtures
    end
  end
end
