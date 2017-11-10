#require 'dm-core'
#require 'dm-migrations'
#DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw3.db")

class Student
  include DataMapper::Resource
  property :student_id, Integer, :key => true
  property :firstname, String, :required => true
  property :lastname, String, :required => true
  property :birthday, DateTime, :required => true
  property :address, String, :required => true
end

DataMapper.finalize
#DataMapper.auto_migrate!