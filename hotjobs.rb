require 'rubygems'
require 'net/http'
require 'hpricot'
require 'active_record'

class Hotjobs
  END_POINT = "http://hotjobs.yahoo.com/job-search?"
  def initialize(per_page = 30)
    @offset = 0;
    @per_page = per_page
  end
  
  def search(keyword)
    url = URI.escape(END_POINT+"detailed=true&offset="+@offset.to_s+"&kw="+keyword)
    
    doc = Net::HTTP.get(URI.parse(url))
    puts doc
    @result = Hpricot(doc)
  end
  
  def next
    # return false unless (@result.search(".next").size == 0)
    @offset += 30
  end
  
  def attribute(css_path)
    @result.search(css_path).collect {|attr| attr.inner_html}
  end
  
  def company
    attribute(".top > td.c > a")
  end
  
  def job_description
    attribute(".mid > td")
  end
  
  def job_title
    attribute(".top > td.t > a")
  end
end