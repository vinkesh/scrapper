require 'bot.rb'
require 'people_data_mailer.rb'
require 'fastercsv'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'cgi'
require 'logger'
require 'connect_to_linked_in'
require 'monster'
require 'careerbuilder'
require 'dice'
require 'Hoovers'


us_search_match = Proc.new {|message| message.body.match(/^search_us/i) ? true : false }
us_handler = Proc.new do |message, jabber_client|
  log_and_perform(message) do
    begin
      keywords = message.body.strip.gsub(/^search_us/i, "").split(",").collect {|keyword| keyword.strip }
      sites = [Monster.new(50), CareerBuilder.new(30), Dice.new(50)]
      company_list = search_companies_for(sites, keywords, message, jabber_client, "US")
  
      logger.info "Companies found :: #{company_list.join(", ")}"
      hoovers company_list, message, jabber_client
    rescue => e
      puts "#{e.backtrace}"
    end
  end
end

india_search_match = Proc.new {|message| message.body.match(/^search_ind/i) ? true : false }
india_handler = Proc.new do |message, jabber_client| 
  log_and_perform(message) do
    keywords = message.body.strip.gsub(/^search_ind/i, "").split(",").collect {|keyword| keyword.strip }
    sites = [MonsterIndia.new(50), Naukri.new(50)]
    company_list = search_companies_for(sites, keywords,  message, jabber_client, "INDIA")
  
    logger.info "COMPANIES FOUND :: #{company_list.join(", ")}"
    hoovers company_list, message, jabber_client
  end
end

l_auth_matcher = Proc.new {|message| message.body.match(/^l_auth/i) ? true : false }
l_auth_handler = Proc.new do |message, client|
  begin
    log_and_perform(message) do
        puts message.inspect
        puts linked_in_obj.inspect
        linked_in_obj.request_token
        logger.info "Auth URL :: #{linked_in_obj.authorize_url}"
        reply(message.from, linked_in_obj.authorize_url, client)
    end
  rescue => e
    logger.error "[ERROR] Token Request Failed :: #{e}"
    puts "error :: #{e}"
  end
end

l_verify_matcher = Proc.new {|message| message.body.match(/^l_verify/i) ? true : false }
l_verify_handler = Proc.new do |message, client|
  begin
    log_and_perform(message) do
      verifier = message.body.gsub(/^l_verify/,"").strip
      linked_in_obj.authorize_from_request(verifier)
      logger.info "Verified.."
      reply message.from, "You can now search for people profile", client
    end
  rescue => e
    logger.error "[ERROR] Verification Failed :: #{e}"
    reply message.from, "Error :: #{e}", client
  end
end

l_search_matcher = Proc.new {|message| message.body.match(/^l_search/i) ? true : false }
l_search_handler = Proc.new do |message, client|
  begin
    log_and_perform(message) do
      keywords = message.body.gsub(/^l_search/,"").strip.gsub(/[,:;]/," ")
      profiles = linked_in_obj.search_all(keywords) do |keywords, start| 
        response = linked_in_obj.search_profile(keywords, start)
        result = LinkedIn.parse_profile_response(response.body)
        logger.info "Downloaded #{start} out of #{result.last}"
        result
      end
      file_name = "linked_in/search_profiles_#{Date.today.strftime("%d_%b_%Y")}_#{Time.now.to_i}.txt"
      logger.info "People Data in File :: #{file_name}"
      LinkedIn.write_to_file(profiles, file_name)
      PeopleDataMailer.deliver_profile_data( clean(message.from), keywords, clean(message.to), "#{file_name}")
      reply(message.from, "Downloded #{profiles.size} Profiles. Sending setails via email", client)
    end
  rescue => e
    logger.error "[ERROR] Verification Failed :: #{e}"
    puts "error :: #{e.backtrace}"
  end
end

def log_and_perform message
  logger.info "================================================================================="
  logger.info "RECIEVED FROM :: #{clean(message.from)}"
  logger.info "CHAT BODY     :: #{message.body}"
  start_time = Time.now
  logger.info "START TIME    :: #{start_time}" 
  yield
  logger.info "TIME TAKEN    :: #{Time.now - start_time} Secs" 
  logger.info "---------------------------------------------------------------------------------"
end

def clean email
  email.to_s.gsub(/\/.*/, "")
end

def search_companies_for sites, keywords, message="", jabber_client = nil, country="us"
  begin
    company_hash = Hash.new {|hash, key| hash[key] = []}

    keywords.each do |keyword|
      sites.each do |site|
        logger.info "Searching #{site.class} for #{keyword} ..."
        site.search(keyword)
        site.company.uniq.each do |comp|
          comp = CGI.unescapeHTML(comp)
          company_hash[comp] <<= keyword unless comp.match(/Confidential/i)
        end
      end
    end

    csv_string = FasterCSV.generate do |csv|
      company_hash.each do |key, value|
        csv<< [key, value.uniq].flatten
      end
    end

    file_name = "csv/Company_by_multiple_keywords_#{country}_#{Time.now.to_i}.csv"
    file = File.new(file_name, "w")
    file.write(csv_string)
    file.close

    company_list = company_hash.collect {|key, value| key}
    # PeopleDataMailer.deliver_company_data( clean(message.from), keywords.join(", "), clean(message.to), "#{file_name}")
    # reply(message.from, "*Companies found*::\n #{company_list.join("\n")}\n *Sending the details by mail*", jabber_client)
  rescue => e
    # reply(message.from, "Error :: #{e}", jabber_client)
    logger.error "[ERROR] :: #{e.backtrace.join("\n")} \n"
  end
  company_list
end

def reply to_email, message, jabber_client
  msg = Jabber::Message.new(clean(to_email), message)
  msg.type = :chat
  jabber_client.send(msg)
end

def hoovers companies, message = "", jabber_client=nil
  begin
    file_list = download_people_date_for companies
    zipped_file_name = "zipped/people_data_#{Time.now.to_i}.zip"
    unless file_list.blank?
      system("zip #{zipped_file_name} \"#{file_list.join("\" \"")}\"")
      logger.info "zip completed for files :: #{file_list.join(" ; ")}"
      logger.info "zipzed files:: #{zipped_file_name}"
     # PeopleDataMailer.deliver_people_data(clean(message.from), companies[0..20].join(", "), clean(message.to), "#{zipped_file_name}")
      # reply(message.from, "Downloaded Data. Sending them via email..", jabber_client)
    else
      # reply(message.from, "Company not found", jabber_client)
    end
  rescue Exception => e
    logger.error "#{e}"
    # reply(message.from, "error #{e}", jabber_client)
  end
end

def download_people_date_for companies
  file_list = []
  companies.each do |cmp| 
    begin
      logger.info "Downloading People data for :: #{cmp}";
      file_name = hoovers_object.search_and_download(cmp)
      file_list << file_name if file_name
    rescue => e
      logger.error "Unable to download #{cmp}"
      logger.error "Error :: #{e}"
    end
  end
  file_list
end

def hoovers_object
  @hoovers_object ||= lambda{ hvr = Hoovers.new ; hvr.login ; hvr }.call
end

def logger
  @logger ||= configure_logger
end

def configure_logger
  log = Logger.new("logs/spidey.log")
  log.level = Logger::INFO
  # log.datetime_format = "%Y-%m-%d %H:%M:%S"
  log
end

def linked_in_obj
  @linked_in ||= lambda{ puts "hereeee"; LinkedIn.new }.call
end
# 
# b = Bot.new
# b.add_matcher(MessageParser.new(us_search_match, us_handler, "search_us <keyword>,<keyword>..", "searches US Job Portals for comma seperated list of <keywords> and returns list of companies"))
# b.add_matcher(MessageParser.new(india_search_match, india_handler, "search_ind <keyword>,<keyword>..", "searches INDIAN Job Portals for comma seperated list of <keywords> and returns list of companies"))
# b.add_matcher(MessageParser.new(l_auth_matcher, l_auth_handler, "l_auth", "Returns authorization url, so as to authorize this application to use linked in on behalf"))
# b.add_matcher(MessageParser.new(l_search_matcher, l_search_handler, "l_search <keyword>;<keyword>...", "Returns profile information searched by given keywords"))
# b.add_matcher(MessageParser.new(l_verify_matcher, l_verify_handler, "l_verify <verification code>", "Send your Verification Code given by linked in"))
# b.listen 

sites = [Monster.new(50), CareerBuilder.new(30), Dice.new(50)]
companies = search_companies_for(sites, ["ruby", "lean", "agile", "scrum"], "", nil, "US")
hoovers(companies)