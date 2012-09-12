require 'rubygems'
require 'net/http'
require 'hpricot'
require 'active_record'

class Dice
  END_POINT = "http://seeker.dice.com/jobsearch/servlet/JobSearch?op=300&Ntk=JobSearchRanking&Ntx=mode+matchall&QUICK=1&SORTSPEC=0"
  def initialize(per_page = 30)
    @offset = 0;
    @per_page = per_page
  end
  
  def search(keyword)
    url = URI.escape(END_POINT+"&No="+@offset.to_s+"&NUM_PER_PAGE="+@per_page.to_s+"&FREE_TEXT="+keyword)
    doc = Net::HTTP.get(URI.parse(url))
    @result = Hpricot(doc)
  end
  
  def next
    @offset += @per_page
  end
  
  # def attribute(css_path)
  #   @result.search(css_path).collect {|attr| attr.inner_html}
  # end
  
  def company
    links = @result.search(".summary tr td:nth-child(4) a")

    links.collect(&:inner_html)
  end
  
  def job_description
    description = @result.search(".summary tr td div div span")
    description.collect{|desc| desc.inner_html.gsub(/<b>.*<\/b>/, "")}
  end
  
  def job_title
    links = @result.search(".summary tr td a")
    job_title = links.select {|link| link.attributes["title"].blank? && link.attributes["onclick"].blank?}
    job_title.collect(&:inner_html)
  end
end