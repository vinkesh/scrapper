require 'rubygems'
require 'net/http'
require 'hpricot'
require 'active_record'

class Naukri
  END_POINT = "http://www.naukri.com"

  def initialize(per_page = 40)
    @page = 1
    @per_page = per_page
    @agent = Mechanize.new
    @search_page = @agent.get(END_POINT)
  end
  
  def search(keyword)
    @result_page = @search_page.form_with(:name => "quickbar") do |f|
      f.qp = keyword
    end.submit
  end
  
  def next
    # return false unless (@result.search(".pagingLinkNext").size == 0) 
    @page += 1 
  end
  
  def attribute(css_path)
    @result.search(css_path).collect {|attr| attr.inner_html}
  end
  
  def company
     (@result_page/".jRes//b").map{|r| r.inner_html}
  end
  
  def job_description
    (@result_page/".jRes/a/em").map{|r| r.text}
  end
  
  def job_title
    (@result_page/".jRes/a/strong").map{|r| r.text}
  end
end















