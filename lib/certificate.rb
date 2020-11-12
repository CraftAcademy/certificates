require './lib/certificate_generator'
require 'bitly'

class Certificate
  include DataMapper::Resource
  include CertificateGenerator

  property :id, Serial
  property :identifier, Text
  property :created_at, DateTime
  property :certificate_key, Text
  property :image_key, Text

  belongs_to :delivery
  belongs_to :student

  before :save do
    student_name = self.student.full_name
    course_name = self.delivery.course.title
    generated_at = self.created_at.to_s
    self.identifier = Digest::SHA256.hexdigest("#{student_name} - #{course_name} - #{generated_at}")
    self.save
  end

  before :destroy do
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])

    certificate_key = bucket.object(self.certificate_key)
    image_key = bucket.object(self.image_key)

    certificate_key.delete
    image_key.delete
  end

  def image_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{self.image_key}"
  end

  def certificate_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{self.certificate_key}"
  end

  def stats
    # Bitly.use_api_version_3
    bitly = Bitly::API::Client.new(token: ENV['BITLY_TOKEN'])
    begin
      bitly.lookup(self.bitly_lookup).global_clicks
    rescue
      0
    end
  end

  def bitly_lookup
    server = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
    "#{server}#{self.identifier}"
  end

  def details
    @details ||= {
      name: self.student.full_name,
      date: self.delivery.start_date.to_s,
      email: self.student.email,
      completed: self.student.completed,
      course_name: self.delivery.course.title,
      course_desc: self.delivery.course.description,
      verify_url: [URL, self.identifier].join('')
    }
  end

  def filename
    @filename ||= [
      self.details[:name],
      self.details[:date],
      self.details[:course_name]
    ].join('_').downcase.gsub!(/\s/, '_')
  end
end
