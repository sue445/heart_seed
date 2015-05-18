require "roo"
require "active_support/all"
require "active_record"
require "yaml"
require "activerecord-import"

begin
  require "roo-xls"
rescue LoadError
end

module HeartSeed
  autoload :Converter , "heart_seed/converter"
  autoload :DbSeed    , "heart_seed/db_seed"
  autoload :Helper    , "heart_seed/helper"
  autoload :Version   , "heart_seed/version"
end

require "heart_seed/railtie" if defined?(Rails)
