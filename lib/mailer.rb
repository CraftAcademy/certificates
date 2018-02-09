require 'mail'
require 'dotenv'

module Mailer
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/"

  mail_options = {
    address: ENV['SMTP_ADDRESS'],
    port: ENV['SMTP_PORT'],
    domain: ENV['SMTP_DOMAIN'],
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  Mail.defaults do
    delivery_method :smtp, mail_options
  end

  def self.send_mail(details, filename)
    mail = Mail.new do
      from     "The course team <#{ENV['SMTP_FROM']}>"
      to       "#{details[:name]} <#{details[:email]}>"
      subject  "Course Certificate - #{details[:course_name]}"
      body     File.read('pdf/templates/body.txt')
      add_file filename: "#{filename}.pdf",
               mime_type: 'application/x-pdf',
               content: File.read("#{PATH}#{filename}.pdf")
    end

    mail.deliver
  end
end
