require 'open-uri'

# A base class for http availability checkers.
class Checker

  # (Array<String>) => Hash<String => Boolean>
  def check(urls)
    urls.map do |url|
      [ url, url_accessibility(formatted_url(url)) ]
    end.to_h
  end

  private

    # (String) => String
    def formatted_url(url)
      url.match(/https?/) ? url : 'http://' + url
    end

end
