require 'rubygems'
require 'net/http'
require 'hpricot'
require 'active_record'

class Monster
#  END_POINT = "http://jobsearch.monster.com/PowerSearch.aspx?"
  END_POINT = "http://jobsearch.monster.com/search/?"

  def initialize(per_page = 30)
    @page = 1
    @per_page = per_page
    @result = Hpricot("<p> new </p>")
  end
  
  def search(keyword)
    url = URI.escape(END_POINT+"pg="+@page.to_s+"&pp="+@per_page.to_s+"&q="+keyword)
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
    attribute(".company>a")
  end
  
  def job_description
    attribute(".description")
  end
  
  def job_title
    attribute(".jobTitle")
  end
end



# m = Monster.new
# m.search("ruby")
# puts m.company
# puts m.result.search("//input[@name='job']../../td[2]/span[@class='txt_grey']").inspect