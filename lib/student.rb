class Student
  include DataMapper::Resource

  property :id, Serial
  property :full_name, String
  property :email, String, required: true
  property :completed, Boolean, default: true
  property :type, Integer, default: 2

  has n, :deliveries, through: Resource
  has n, :certificates
end
