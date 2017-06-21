require 'prawn'
require 'rmagick'
require 'aws-sdk'
require 'bitly'
require 'mail'
require 'dotenv'

module CertificateGenerator
  Dotenv.load
  Bitly.use_api_version_3
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/"
  TEMPLATE = File.absolute_path('./pdf/templates/ca-certificate.jpg')
  URL = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  S3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  BITLY = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])

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

  def self.generate(certificate)
    details = {
      name: certificate.student.full_name,
      date: certificate.delivery.start_date.to_s,
      email: certificate.student.email,
      course_name: certificate.delivery.course.title,
      course_desc: certificate.delivery.course.description,
      verify_url: [URL, certificate.identifier].join('')
    }

    file_name = [
      details[:name], details[:date], details[:course_name]
    ].join('_').downcase.gsub!(/\s/, '_')

    certificate_output = "#{PATH}#{file_name}.pdf"
    image_output = "#{PATH}#{file_name}.jpg"

    make_prawn_document(details, certificate_output)
    make_rmagic_image(certificate_output, image_output)

    if ENV['RACK_ENV'] == 'production'
      upload_to_s3(certificate_output, image_output)
      send_email(details, file_name)
    end

    { certificate_key: certificate_output, image_key: image_output }
  end

  # private

  def self.make_prawn_document(details, output)
    indent_px = 270
    File.delete(output) if File.exist?(output)

    pdf_opts = {
      page_size: 'A4', background: TEMPLATE, background_scale: 0.5,
      page_layout: :landscape, left_margin: 0, right_margin: 30,
      top_margin: 0, bottom_margin: 0, skip_encoding: true
    }

    Prawn::Document.generate(output, pdf_opts) do |pdf|
      pdf.move_down 215
      pdf.font 'assets/fonts/Gotham-Medium.ttf'
      pdf.text details[:name], size: 40, color: 'FCFCFC', indent_paragraphs: indent_px
      pdf.move_down 55
      pdf.font 'assets/fonts/Gotham-Medium.ttf'
      pdf.text details[:course_name], indent_paragraphs: indent_px, size: 30, color: 'FCFCFC'
      pdf.text details[:course_desc], indent_paragraphs: indent_px, size: 20, color: 'FCFCFC'
      pdf.move_down 75
      pdf.text "Gothenburg #{details[:date]}", align: :right, size: 12, color: 'ffffff'
      pdf.move_down 95
      pdf.text "To verify the authenticity of this Certificate, please visit: #{get_url(details[:verify_url])}", indent_paragraphs: indent_px, size: 8, color: 'ffffff'
    end
  end

  def self.make_rmagic_image(certificate_output, output)
    im = Magick::Image.read(certificate_output)
    im[0].write(output)
  end

  def self.upload_to_s3(certificate_output, image_output)
    s3_certificate_object = S3.bucket(ENV['S3_BUCKET']).object(certificate_output)
    s3_certificate_object.upload_file(certificate_output, acl: 'public-read')
    s3_image_object = S3.bucket(ENV['S3_BUCKET']).object(image_output)
    s3_image_object.upload_file(image_output, acl: 'public-read')
  end

  def self.send_email(details, file)
    mail = Mail.new do
      from     "The course team <#{ENV['SMTP_FROM']}>"
      to       "#{details[:name]} <#{details[:email]}>"
      subject  "Course Certificate - #{details[:course_name]}"
      body     File.read('pdf/templates/body.txt')
      add_file filename: "#{file}.pdf", mime_type: 'application/x-pdf', content: File.read("#{PATH}#{file}.pdf")
    end
    mail.deliver
  end

  def self.get_url(url)
    BITLY.shorten(url).short_url
  rescue
    url
  end
end
