require 'rubygems'
require 'net/http'
require 'hpricot'
require 'active_record'

class MonsterIndia
  attr_accessor :result
  END_POINT = "http://jobsearch.monsterindia.com/searchresult.html?"

  def initialize(per_page = 40)
    @page = 1
    @per_page = per_page
    @result = Hpricot("<p> new </p>")
  end
  
  def search(keyword)
    url = URI.escape(END_POINT+"rfr=searchresult;"+"fts="+keyword)
    doc = Net::HTTP.get(URI.parse(url))
    @result = Hpricot(doc)
  end
  
  def next
    # return false unless (@result.search(".pagingLinkNext").size == 0) 
    @page += 1 
  end
  
  def attribute(css_path)
    @result.search(css_path).collect {|attr| attr.inner_html}
  end
  
  def company
     @result.search("//input[@name='job']../../td[2]/span[@class='txt_grey']").map{|e| n2 = e.next.next; n2.to_s.strip.blank? ? n2.next.inner_html.to_s.strip : n2.to_s.strip}
  end
  
  def job_description
    @result.search("//input[@name='job']../../td[2]/div/span").map {|x| x.next.to_s.strip}
  end
  
  def job_title
    @result.search("//input[@name='job']../../td[2]/a[1]").map{|e|  e.inner_html.strip}
  end
end


# m = MonsterIndia.new
# m.search("ruby")
# puts m.company
# puts m.result.search("//input[@name='job']../../td[2]/span[@class='txt_grey']").inspect