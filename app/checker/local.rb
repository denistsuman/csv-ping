require 'socket'
require 'timeout'

# A class to check http availability using requests from localhost.
class Checker::Local < Checker

  private

    ##
    # Returns an availability of the url.
    #
    # (String) => Boolean
    def url_accessibility(url)
      open(url).status.last == 'OK'
    rescue ::SocketError, Timeout::Error, Errno::ECONNREFUSED, OpenURI::HTTPError
      false
    end

end


