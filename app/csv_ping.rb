require 'csv'
require_relative 'checker'
require_relative 'checker/local'
require_relative 'checker/remote'

# A class that returns http availability statuses of all hosts in the provided CSV.
class CsvPing

  # (String) => void
  def initialize(csv_path)
    @csv_path = csv_path
  end

  ##
  # Checks http availabilities using the local checker.
  # If any hosts are not available, retries them with the remote checker, in order to exclude
  # local issues.
  #
  # () => Hash<String => Boolean>
  def perform
    local_check = perform_local_check
    remote_check = perform_remote_check(local_check)

    pp local_check.select { |_url, availability| availability }.merge(remote_check)
  end

  private

    # () => Array<String>
    def urls
      @urls ||= CSV.read(@csv_path, headers: true).by_col[0]
    end

    # () => Hash<String => Boolean>
    def perform_local_check
      Checker::Local.new.check(urls)
    end

    # (Hash<String => Boolean>) => Hash<String => Boolean>
    def perform_remote_check(local_check)
      urls_to_check = local_check.map { |site, availability| site unless availability }.compact

      Checker::Remote.new.check(urls_to_check)
    end

end
