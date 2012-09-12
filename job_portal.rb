require 'rubygems'
require 'active_record'
require 'monster.rb'
require 'careerbuilder.rb'
require 'hotjobs.rb'
require 'dice.rb'
require 'naukri.rb'
require 'monster_india.rb'
require 'schema.rb'
require 'hoovers.rb'
require 'fastercsv'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

DataBase::create_connection


class JobPortal < ActiveRecord::Base
  def initializer(job_portal_class)
    @klass = job_portal_class
  end

  def find_and_store_all(keyword)
    search(keyword)
    res = store()
  end

  def search(keyword)
    @keyword = keyword
    @klass.search(@keyword)
  end

  def store()
    JobPortal.create!(results)
    results
  end

  def results
    companies, job_titles, job_descriptions = @klass.company, @klass.job_title, @klass.job_description
    results = []
    return [] unless companies
    companies.each_index do |index|
      results << {:company => companies[index], :job_title => job_titles[index], 
                  :job_description => job_descriptions[index] , :search_keyword => @keyword}
    end
    results
  end

  def companies
    @klass.company if @klass
  end

  def self.distinct_companies 
    find(:all, :select => "distinct(company)").collect(&:company)
  end
end  
