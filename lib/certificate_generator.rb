require 'prawn'
require 'rmagick'
require 'aws-sdk'
require 'bitly'
require 'dotenv'

module CertificateGenerator
  Dotenv.load
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/".freeze
  URL = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  S3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  BITLY = Bitly::API::Client.new(token: ENV['BITLY_TOKEN'])

  def self.generate(certificate)
    certificate_output = "#{PATH}#{certificate.filename}.pdf"
    image_output = "#{PATH}#{certificate.filename}.jpg"
    make_prawn_document(certificate.details, certificate_output)
    make_rmagic_image(certificate_output, image_output)

    if ENV['RACK_ENV'] == 'production'
      upload_to_s3(certificate_output, image_output)
    end

    { certificate_key: certificate_output, image_key: image_output }
  end

  def self.make_prawn_document(details, output)
    # type = details[:completed] ? 'excellence' : 'participation'
    case details[:type]
    when 1
      type = 'excellence'
    when 2
      type = 'completion'
    when 3
      type = 'participation'
    end
    template = File.absolute_path("./pdf/templates/ca-certificate-of-#{type}.jpg")
    indent_px = 270
    File.delete(output) if File.exist?(output)

    pdf_opts = {
      page_size: 'A4', background: template, background_scale: 0.5,
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
      pdf.move_down 105
      pdf.text "To verify the authenticity of this Certificate, please visit: #{get_url(details[:verify_url])}", indent_paragraphs: (indent_px - 200), size: 8, color: 'ffffff'
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

  def self.get_url(url)
    BITLY.shorten(url).short_url
  rescue
    url
  end
end
