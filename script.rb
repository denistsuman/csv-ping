require_relative 'app/csv_ping'

CsvPing.new(ARGV[0]).perform
