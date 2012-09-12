require 'rubygems'
require 'active_record'

module DataBase
  def self.create_connection 
    ActiveRecord::Base.establish_connection(
          :adapter => "mysql",
          :database => "spidey",
          :host => "localhost",
          :username => "root",
          :password => ""
    )
  end

  def self.create_table
    ActiveRecord::Schema.define do
      create_table :job_portals do |t|
        t.string :company
        t.string :job_title
        t.string :job_description
        t.string :search_keyword
      end
    end
  end

  def self.drop_table
    ActiveRecord::Schema.define do
      drop_table :job_portals
    end
  end  
end