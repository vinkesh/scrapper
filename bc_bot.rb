require 'rubygems'
#require 'bot'
#require 'active_record'
require './monster.rb'
#require './careerbuilder.rb'
require './hotjobs.rb'
require './dice.rb'
require './naukri.rb'
#require './monster_india.rb'
require './hoovers.rb'
require 'csv'
# 
# require 'cgi'

#bc_match = Proc.new{|message| true}
#bc_handler = Proc.new{|message, jc| puts message.body; sleep(4); reply(message.from, message.body.reverse, jc); }

# ls_match = Proc.new {|message| message.body.to_s.match(/^ls/) ? true : false }
# ls_handler = Proc.new{|message| puts message.body; `#{message.body}`}
# 
# cat_match = Proc.new {|message| message.body.to_s.match(/^cat/) ? true : false }
# cat_handler = Proc.new{|message| puts message.body; `#{message.body}`}

def reply to_email, message, jabber_client
  msg = Jabber::Message.new(clean(to_email), message)
  msg.type = :chat
  jabber_client.send(msg)
end

def clean email
  email.to_s.gsub(/\/.*/, "")
end


# b = Bot.new
# b.add_matcher(MessageParser.new(bc_match, bc_handler, "<message>", "reverses the message"))
# b.add_matcher(MessageParser.new(ls_match, ls_handler, "ls <options>", "uses the nix ls command and its options"))
# b.add_matcher(MessageParser.new(cat_match, cat_handler, "cat <filename>", "uses the nix cat command and its options"))
# b.listen

# # CGI.unescapeHTML
# 
keywords = ["ruby", "agile", "scrum", "Open source"]
new_keywords = ["Agile", "Lean", "Scrum", "Open Source"]
sites = [Monster.new(100), Hotjobs.new(50), Dice.new(50)]
#indian_sites = [MonsterIndia.new(50), Naukri.new(50)]
blacklist = ["Confidential"]

company_hash = Hash.new {|hash, key| hash[key] = []}

# new_keywords.each do |keyword|
#   puts "****************************************************"
#   puts keyword
#   sites.each do |site|
#     site.search(keyword)
#     site.company.uniq.each do |comp|
#       comp = CGI.unescapeHTML(comp)
#       company_hash[comp] <<= keyword unless comp.match(/Confidential/i)
#     end
#     p company_hash
#   end
# end

company_hash = {"Barnes & Noble.com"=>["Agile"], "EmLogis, Inc."=>["Agile"], "Solution Partners, Inc."=>["Agile", "Scrum"], "SolutionsIQ"=>["Agile"], "Vaco Technology"=>["Agile", "Scrum", "Open Source"], "Genesis10"=>["Agile"], "Cisco Systems, Inc."=>["Agile", "Open Source"], "Unimed Direct, LLC"=>["Agile"], "L-3 C2S2"=>["Agile"], "CyberCoders"=>["Agile", "Lean", "Scrum", "Open Source"], "Informa"=>["Agile"], "IBM"=>["Agile", "Lean", "Scrum"], "Booz Allen Hamilton"=>["Agile"], "ValueClick, Inc."=>["Agile", "Scrum"], "Fry, Inc."=>["Agile"], "TEKsystems"=>["Agile", "Scrum", "Open Source"], "Innovim"=>["Agile", "Scrum"], "TASC, Inc."=>["Agile"], "Kforce Professional Staffing"=>["Agile", "Lean", "Scrum", "Open Source"], "Patrick Berends & Associates"=>["Agile"], "CSC"=>["Agile", "Scrum", "Open Source"], "McKesson"=>["Agile"], "Volt Workforce Solutions"=>["Agile", "Lean", "Scrum", "Open Source"], "Adecco Engineering & Technical"=>["Agile", "Lean", "Scrum"], "Buxton Consulting"=>["Agile", "Scrum"], "BCforward"=>["Agile", "Lean"], "Beacon Hill Staffing Group"=>["Agile"], "Ntelicor LP"=>["Agile"], "Eliassen Group"=>["Agile"], "Experis, COMSYS"=>["Agile", "Lean", "Scrum"], "Kaplan Test Prep & Admissions"=>["Agile", "Scrum"], "Apex Systems"=>["Agile"], "Guidewire Software"=>["Agile"], "United Graphics"=>["Agile"], "Jumptap, Inc."=>["Agile"], "CIBER, Inc."=>["Agile"], "Princeton Information"=>["Agile", "Scrum"], "TRINITY DATABASE SERVICES"=>["Agile"], "Accolo"=>["Agile"], "Tiva Systems"=>["Agile", "Scrum"], "Deloitte"=>["Agile", "Lean"], "Trinine Enterprises"=>["Agile"], "Apple Inc."=>["Agile"], "Kaiser Permanente"=>["Agile", "Lean", "Scrum"], "Hire Solutions"=>["Agile"], "Timberhorn, LLC"=>["Agile"], "JDSU"=>["Agile", "Scrum"], "Advisory Board Company"=>["Agile", "Scrum"], "Winter, Wyman"=>["Agile", "Open Source"], "Deutsche Bank Jacksonville"=>["Agile"], "Zenex Partners"=>["Agile", "Scrum"], "Pariveda"=>["Agile"], "Lockheed Martin"=>["Agile"], "Willis Group US"=>["Agile"], "Innocore Solutions"=>["Agile"], "Parker Hannifin"=>["Lean"], "Alcoa Inc."=>["Lean"], "WESCO Distribution, Inc"=>["Lean"], "Hubbell, Inc."=>["Lean"], "eRichards Consulting"=>["Lean"], "Resolution Technologies"=>["Lean"], "Aerotek"=>["Lean"], "Pentair, Inc."=>["Lean"], "LeanCor"=>["Lean"], "GE Energy"=>["Lean"], "Kimberly Clark"=>["Lean"], "Nissen Chemitec America"=>["Lean"], "Alion Science and Technology"=>["Lean"], "PPL"=>["Lean"], "TE Connectivity"=>["Lean"], "GE Healthcare"=>["Lean"], "Level 3 Communications"=>["Lean"], "Southern Recruiters"=>["Lean"], "VA Premier Healthcare"=>["Lean"], "Cypress Group"=>["Lean"], "Catalyst Health Solutions"=>["Lean"], "NOVACES, LLC"=>["Lean"], "Ingersoll Rand"=>["Lean"], "Fluke Corporation"=>["Lean"], "SGS North America Inc."=>["Lean"], "Tunnell Consulting"=>["Lean"], "Citizens Financial Group"=>["Lean"], "Inova Health System"=>["Lean"], "MRINetwork"=>["Lean", "Open Source"], "Fallon Clinic"=>["Lean"], "Tata Consultancy Services"=>["Lean"], "Kaeppel Consulting, LLC"=>["Lean"], "Hospira"=>["Lean"], "Hart & Cooley, Inc"=>["Lean"], "Guardian Industries Corp"=>["Lean"], "Royce Ashland Group"=>["Lean"], "The Albrecht Group"=>["Lean"], "LabCorp"=>["Lean"], "Hendrick Metal Products"=>["Lean"], "Hendrick Screen Company"=>["Lean"], "Goodrich Corporation"=>["Lean"], "Gerdau"=>["Lean"], "Rockwell Automation"=>["Lean"], "Armstrong World Industries Inc"=>["Lean"], "Greif, Inc"=>["Lean"], "ITBMS"=>["Lean"], "Emerson Process Management - Valve Automation"=>["Lean"], "CDI Corporation"=>["Lean", "Scrum"], "Eagle Industries"=>["Lean"], "Strategic Search Partners"=>["Lean"], "SELECT STAFFING"=>["Lean"], "UnitedHealth Group"=>["Lean", "Scrum"], "MorningStar Resource Group"=>["Lean"], "Maetrics"=>["Lean"], "Reliance Recruiting LLC"=>["Lean"], "INT Technologies, LLC"=>["Scrum"], "Dydacomp Development Corp"=>["Scrum"], "Technisource"=>["Scrum", "Open Source"], "OLSA Resources, Inc."=>["Scrum"], "ACS, A Xerox Company"=>["Scrum"], "DIRECTV"=>["Scrum"], "RealtyTrac Inc"=>["Scrum"], "SoNoted"=>["Scrum"], "First Allied Securities, Inc."=>["Scrum"], "RMK Consulting"=>["Scrum"], "MissionStaff"=>["Scrum"], "Techlink, Inc."=>["Scrum"], "Fujitsu"=>["Scrum"], "TeleTech"=>["Scrum"], "Fandango"=>["Scrum"], "UST Global"=>["Scrum"], "Epsilon"=>["Scrum"], "AIM Consulting Group"=>["Scrum"], "The Essex Recruiting Group"=>["Scrum"], "Direct Capital Corporation"=>["Scrum"], "CompuCom Application Services"=>["Scrum"], "Manpower"=>["Scrum"], "Bridge Energy Group"=>["Scrum"], "Ask Staffing"=>["Scrum"], "Computer Technology Services"=>["Scrum"], "Citrix"=>["Scrum"], "ING DIRECT"=>["Scrum"], "AT&T"=>["Scrum"], "Michael Baker Corporation"=>["Scrum"], "DEW SOFTECH, Inc"=>["Scrum"], "Bloomberg"=>["Scrum"], "Energy Enterprise Solutions (E"=>["Scrum"], "BSquare Corporation"=>["Scrum"], "Agreeya Solutions"=>["Scrum"], "A.C.Coy"=>["Scrum"], "MISI"=>["Scrum"], "7 Delta, Inc"=>["Scrum"], "GfK Custom Research"=>["Scrum"], "Next Century Corporation"=>["Open Source"], "IPsoft,  Inc."=>["Open Source"], "Numeric"=>["Open Source"], "Identified"=>["Open Source"], "HP"=>["Open Source"], "The Bivium Group"=>["Open Source"], "ExcelaCom"=>["Open Source"], "Chase"=>["Open Source"], "Twenty First Century Communica"=>["Open Source"], "Salesforce.com"=>["Open Source"], "Synergy Network Solutions"=>["Open Source"], "Systems Engineering Services"=>["Open Source"], "e-Dialog"=>["Open Source"], "TerpSys"=>["Open Source"], "The Madison Group"=>["Open Source"], "Contegix"=>["Open Source"], "Staffmark"=>["Open Source"], "Regional Transportation Distri"=>["Open Source"], "PegaStaff"=>["Open Source"], "Rochester Electronics"=>["Open Source"], "Google"=>["Open Source"], "Harvey Nash"=>["Open Source"], "Amazon Corporate LLC"=>["Open Source"], "DigiFlight , Inc."=>["Open Source"], "VivanTech, Inc."=>["Open Source"], "ITC Infotech (USA) Inc"=>["Open Source"], "E*TRADE"=>["Open Source"], "InterNAP Network Services"=>["Open Source"], "Webair"=>["Open Source"], "Project One"=>["Open Source"], "AT&T Interactive"=>["Open Source"], "Modis, Inc."=>["Open Source"], "MyLife.com"=>["Open Source"], "Webalo, Inc."=>["Open Source"], "GDR Group"=>["Open Source"], "BlueAlly LLC"=>["Open Source"], "SonicWALL, Inc."=>["Open Source"], "Cambridge Systematics"=>["Open Source"], "Partners Healthcare System"=>["Open Source"], "Kane Partners LLC"=>["Open Source"], "Biztek People Inc"=>["Open Source"], "Originate Labs"=>["Open Source"], "Vicor Corp"=>["Open Source"], "Everest Consultants, Inc."=>["Open Source"], "LDS Church"=>["Open Source"], "Marcum Search LLC"=>["Open Source"], "Fidelity Investments"=>["Open Source"], "Netsource, Inc."=>["Open Source"], "Emory University"=>["Open Source"], "SOS International Ltd."=>["Open Source"], "Vaco Resources"=>["Open Source"], "Xyratex International, Inc."=>["Open Source"], "Monster"=>["Open Source"]}
# csv_string = CSV.generate do |csv|
#   company_hash.each do |key, value|
#     csv<< [key, value.uniq].flatten
#   end
# end
# 
# file = File.new("csv/Company_by_multiple_keywords_us_7_sep.csv", "w")
# file.write(csv_string)


hvr = Hoovers.new
hvr.login
total, counter = company_hash.size, 0
company_hash.each do |comp, values| 
  counter += 1
  puts "downloading #{comp} :: #{counter} out of #{total}";
  begin
    hvr.search_and_download(comp)
  rescue
    puts "Unable to download for #{comp}"
  end
end

