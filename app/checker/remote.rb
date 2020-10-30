require 'json'

# A class to check http availability using requests from a remote service (check-host.net currently).
class Checker::Remote < Checker

  REQUEST_BASE = 'https://check-host.net/check-http?host={URL}'
  RESULT_BASE = 'https://check-host.net/check-result/{ID}'
  KYIV_HOST = 'ua2.node.check-host.net'
  ATTEMPT_COUNT = 10

  private

    ##
    # Returns an availability of the url.
    #
    # (String) => Boolean
    def url_accessibility(url)
      resp = response(url)
      resp && resp.dig(0, 0) == 1 # check the response body
    end

    ##
    # check-host.net returns a result with 2 steps:
    # 1st: to request the host availabilities, which returns the request id
    # 2nd: to get the request result with the received id
    #
    # JSON Response body:
    # {
    #   ...
    #   "ua2.node.check-host.net": [
    #     [
    #       1,
    #       0.141490936279297,
    #       "Found",
    #       "200",
    #       "18.157.219.111"
    #     ]
    #   ]
    # }
    #
    # (String) => Hash
    def response(url)
      request_id = request_availabilities(url)['request_id']
      result_url = RESULT_BASE.gsub('{ID}', request_id)

      # We need the loop because the 2nd step is becoming available on the server not immediately,
      # but with some delay.
      ATTEMPT_COUNT.times do |i|
        resp = open_json(result_url)[KYIV_HOST]
        break resp if resp
      end
    end

    ## JSON response body:
    # {
    #   "nodes": [...]
    #   "ok": 1,
    #   "permanent_link": "https://check-host.net/check-report/e1da4d6k56f",
    #   "request_id": "e1da4d6k56f"
    # }
    #
    # (String) => Hash
    def request_availabilities(url)
      request_url = REQUEST_BASE.gsub('{URL}', formatted_url(url))
      open_json(request_url)
    end

    # (String) => Hash
    def open_json(url)
      JSON.parse open(url, 'Accept' => 'application/json').read
    end

end


