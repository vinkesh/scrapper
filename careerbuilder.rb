require 'rubygems'
require 'net/http'
require 'xml'
require 'active_record'

class CareerBuilder
  DEVELOPER_KEY = "WDH13106T0F91QC4Z7TH"
  END_POINT = "http://api.careerbuilder.com/v1/jobsearch?"
  
  def initialize(per_page = 30)
    @parser = LibXML::XML::Parser.new 
    @page = 1
    @per_page = per_page
  end
  
  def search(keyword)
    url = URI.escape(END_POINT+"PageNumber="+@page.to_s+"&PerPage="+@per_page.to_s+"&DeveloperKey="+DEVELOPER_KEY+"&Keywords="+keyword)
    doc = Net::HTTP.get(URI.parse(url))
    @parser.string = doc
    @result = @parser.parse
  end
  
  def next
    @page += 1
  end
  
  def attribute(xpath)
    @result.find(xpath).collect {|attr| attr.content}
  end
  
  def company
    attribute("//Company")
  end
  
  def job_description
    attribute("//DescriptionTeaser")
  end
  
  def job_title
    attribute("//JobTitle")
  end
end