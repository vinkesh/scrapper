require 'rubygems'
require 'action_mailer'

class PeopleDataMailer < ActionMailer::Base

  def people_data(recipient_email, companies, from_mail_id, zipped_file_name)
    recipients      recipient_email
    subject         "People Data for #{companies}"
    from            from_mail_id
    body            ''

    attachment :content_type => "application/zip",
      :body => File.read(zipped_file_name),
      :filename => zipped_file_name.gsub(/.*\//,"")
  end

  def company_data(recipient_email, keywords, from_mail_id, zipped_file_name)
    recipients      recipient_email
    subject         "Company Data for #{keywords}"
    from            from_mail_id
    body            ''

    attachment :content_type => "application/zip",
      :body => File.read(zipped_file_name),
      :filename => zipped_file_name.gsub(/.*\//,"")
  end

  def profile_data(recipient_email, keywords, from_mail_id, file_name)
    recipients      recipient_email
    subject         "Profile Data for #{keywords}"
    from            from_mail_id
    body            ''

    attachment :content_type => "application/zip",
      :body => File.read(file_name),
      :filename => file_name.gsub(/.*\//,"")
  end
end
PeopleDataMailer.delivery_method = :smtp

# PeopleDataMailer.sendmail_settings = {
#   :location       => '/usr/sbin/sendmail',
#   :arguments      => '-i -t -f vinkesh.bot@gmail.com'
# }

PeopleDataMailer.smtp_settings = {
        :address => "bngmisc01.thoughtworks.com",
        :port => 25,
        :domain => "bngmisc01.thoughtworks.com"
}
