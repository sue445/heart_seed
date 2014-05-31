require "heart_seed/version"
require "roo"
require "active_support/all"

module HeartSeed
  HEADER_ROW = 1

  # convert xls to yaml and write to file.
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
  # - id: 1
  #   title: title1
  #   description: description1
  #   created_at: '2014-06-01 12:10:00 +0900'
  # - id: 2
  #   title: title2
  #   description: description2
  #   created_at: '2014-06-02 12:10:00 +0900'
  # ```
  #
  # @param source_file  [String] source xls file
  # @param source_sheet [String]
  # @param dist_file    [String] don't write to file if blank
  # @return [Array<Hash>]
  def self.xls_to_yml(source_file: nil, source_sheet: nil, dist_file: nil)
    xls = Roo::Excel.new(source_file)
    sheet = xls.sheet(source_sheet)
    header_keys = sheet.row(HEADER_ROW)

    response = []

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

      response << row_value
    end

    unless dist_file.blank?
      File.open(dist_file, "w") do |f|
        f.write(YAML.dump(response))
      end
    end

    response
  end
end
