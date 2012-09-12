require 'rubygems'
require 'savon'
require 'mechanize'

class Hoovers
  def initialize(download_directory = "downloads")
    Dir.mkdir(download_directory) unless File.exists?(download_directory)
    @download_directory = download_directory
    @agent = Mechanize.new
  end
  
  def login
    login_page
    index_page if @login_page
  end
  
  def search_and_download(keyword)
    search_result(keyword) if @index_page
    choose_first_result if @search_result_page
    download_people_data 
  end
  
  private
  def login_page
    @login_page = @agent.get('http://subscriber.hoovers.com/H/login/login.html')
  end
  
  def index_page
    @index_page = @login_page.form_with(:name => 'loginForm') do |login_form|
      login_form.j_username = 'tvinod@thoughtworks.com'
      login_form.j_password = 'ThoughtWorks'
    end.submit
  end

  def search_result(company)
    @search_result_page = @index_page.form_with(:name => "searchForm") do |sf|
      sf.searchValue = company
    end.submit
  end

  def choose_first_result
    return unless @search_result_page
    link = @search_result_page.search("tbody#companySearchResults > tr > td > a")
    @company_page = @search_result_page.link_with(:href => link.first.attributes["href"].value).click if link
  end

  def download_people_data
    return unless @company_page
    link = @company_page.search(".downloadLink")
    return unless link
    dwnload_page = @company_page.link_with(:href => link.first.attributes["href"].value).click
    
    d_link = dwnload_page.search(".companyExecutiveDownload")
    return unless d_link
    people_excel_link = dwnload_page.link_with(:href => d_link.first.attributes["href"].value).click
    filename = people_excel_link.filename.gsub!("\"", "")
    people_excel_link.save_as("#{@download_directory}/#{filename}")
    return "#{@download_directory}/#{filename}"
  end
end



hvr = Hoovers.new
hvr.login
begin
  hvr.search_and_download("thoughtworks")
rescue => e
  puts "Unable to download:"
  puts e.backtrace
end
