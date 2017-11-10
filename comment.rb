#require 'dm-core'
#require 'dm-migrations'
#require 'rubygems'
require 'dm-timestamps'

#DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw3.db")

class Comment
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :comment, Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize
#DataMapper.auto_migrate!