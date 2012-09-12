require 'rubygems'
require 'oauth'
require 'uri'
require 'hpricot'
require 'cgi'

class LinkedIn
  APP_KEY = "ZZnM8KDv6SJyXTZv1hjmf5b0yD74WqvvTbALCZJc6JAQBaVrHC62P6-J-yuqefFE"
  SECRET_KEY = "N9P3qxx3Z_a0Il-ChNPa5hsU9fKo0KgFyMf0b6ZhJkfQv3Clo0_ZHVA-fVvV6DY7"
  MAX_COUNT = 25
  MAX_START = 250

  def initialize
    @opts = {
      :site => 'https://api.linkedin.com',
      :request_token_path => '/uas/oauth/requestToken',
      :authorize_path     => '/uas/oauth/authorize',
      :access_token_path  => '/uas/oauth/accessToken'
    }
    @consumer = ::OAuth::Consumer.new(APP_KEY, SECRET_KEY, @opts)
  end

  def request_token(opts = {})
    @request_token = @consumer.get_request_token(@opts.merge(opts))
  end

  def authorize_url
    @request_token.authorize_url
  end

  def authorize_from_request(verifier)
    @verifier = verifier
    oauth_request_token = ::OAuth::RequestToken.new(@consumer, @request_token.token, @request_token.secret)
    access_token = oauth_request_token.get_access_token(:oauth_verifier => verifier)
    @access_token, @access_secret = access_token.token, access_token.secret
  end

  def access_token
    @oauth_access_token ||= ::OAuth::AccessToken.new(@consumer, @access_token, @access_secret)
  end

  def get_profile
    response = access_token.get("http://api.linkedin.com/v1/people/~")
  end
  
  def search_profile(keyword, start = 0)
    response = access_token.get(URI.escape("http://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,industry,public-profile-url,headline,location:(name),summary,specialties,interests))?keywords=#{keyword}&country-code=in&start=#{start}&count=#{MAX_COUNT}"))
  end

  def search_all keywords
    start = 0
    results, result_count = yield keywords, start
    while start < MAX_START && (start + MAX_COUNT) < result_count
      start += MAX_COUNT
      new_results, new_res_count = yield keywords, start
      results << new_results
      results.flatten!
    end
    results.flatten
  end

  def self.parse_profile_response response
    xml = Hpricot.XML(CGI.unescapeHTML(response))
    total_profile_count = (xml/"people").attr("total").to_i
    profiles = []
    (xml/"person").each do |person|
      person_details = {}
      person_details[:id] = (person/"id").inner_html
      person_details[:first_name] = (person/"first-name").inner_html
      person_details[:last_name] = (person/"last-name").inner_html
      person_details[:industry] = (person/"industry").inner_html
      person_details[:public_profile_url] = (person/"public-profile-url").inner_html
      person_details[:headline] = (person/"headline").inner_html
      person_details[:location] = (person/"location/name").inner_html
      person_details[:summary] = (person/"summary").inner_html
      person_details[:specialties] = (person/"specialties").inner_html
      profiles << person_details
    end
    [profiles, total_profile_count]
  end

  def self.write_to_file(profiles, filename)
    file = File.new(filename, "w+")
    profiles.each do |profile|
      file << "Name          :: #{profile[:first_name]} #{profile[:last_name]} \n" 
      file << "Industry      :: #{profile[:industry]} \n" if profile[:industry]
      file << "Public URL    :: #{profile[:public_profile_url]} \n" if profile[:public_profile_url]
      file << "Title         :: #{profile[:headline]} \n" if profile[:headline]
      file << "Location      :: #{profile[:location]} \n" if profile[:location]
      file << "Summary       :: #{profile[:summary]} \n\n" if profile[:summary]
      file << "Specialities  :: #{profile[:specialties]}\n " if profile[:specialties]
      file << "*****************************************************************************************\n"
      file << "*****************************************************************************************\n\n"
    end
    file.close
  end
end
