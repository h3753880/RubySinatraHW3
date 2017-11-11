require 'sinatra'
require 'sinatra/reloader' if development?
require 'dm-core'
require 'dm-migrations'
require './student'
require './comment'

# db conecting string
configure :development, :test do 
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw3.db")
end

configure :production do 
  # DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw3.db")
  # ENV['DATABASE_URL']
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

configure do
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'your_secret'
  # default account
  set :username, "hchien"
  set :password, "scu123"
  set :status, "/"
end

# home (login page)
get '/' do 
  #already login -> go to students page
  if session[:admin]
    redirect '/students'
  end
  
  settings.status = "/logout"
  @title = "Login"
 erb :login
end

# for login
post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect '/students'
  else
    # not match, send back to login page
    @err = "wrong username or password"
    erb :login
  end
end

# new comment page
get '/new_comment' do
  erb :new_comment
end

# comment page
get '/comments' do
  @comments = Comment.all
  erb :comments
end

post '/add_comment' do
  com = Comment.new
  com.name = params[:name]
  com.comment = params[:comment]
  #com.created_at = Time.now
  com.save

  redirect '/comments'
end

# comment's detail page
get '/comments/:id' do
  @comments = Comment.all(:id => params[:id]).first
  erb :comments_detail
end

# students page
get '/students' do
  # check if user login
  if !session[:admin]
    redirect '/'
  end
  
  @students = Student.all
  @title = "Students"
  erb :students
end

# students detail page
get '/students/:id' do 
  # check if user login
  if !session[:admin]
    redirect '/'
  end

  @student = Student.all(:student_id => params[:id]).first
  erb :student_detail
end

# go to the new student page
get '/newstu' do
  # check if user login
  if !session[:admin]
    redirect '/'
  end

  temp = Student.all(:order => :student_id.asc)
  
  if temp.count != 0
    @new_id = temp.last.student_id + 1
  else
    @new_id = 1
  end

  erb :add_students
end

# add a new student
post '/addstu' do 
  # check if user login
  if !session[:admin]
    redirect '/'
  end

  # check birthday format
  if !checkDate(params[:birthday])
    @msg = "Add failed! Please enter the correct birthday format!"
    @students = Student.all
    @title = "Students"
    return erb :students
  end

  # check if the id is repeated
  Student.all.each do |x| 
    if x.student_id == params[:id].to_i
      @msg = "Add failed! Please enter the different student id!"
      @students = Student.all
      @title = "Students"
      return erb :students
    end
  end

  stu = Student.new
  stu.student_id = params[:id]
  stu.firstname = params[:firstname]
  stu.lastname = params[:lastname]
  stu.birthday = params[:birthday] # 2010-05-28T15:36:56.200
  stu.address = params[:address]
  stu.save
  redirect '/students'
end

# go to the edit student page
get '/editpage_stu' do
  # check if user login
  if !session[:admin]
    redirect '/'
  end

  @student = Student.all(:student_id => params[:id]).first

  erb :edit_students
end

#edit a student
post '/edit_stu' do
  # check if user login
  if !session[:admin]
    redirect '/'
  end
  # check birthday format
  if !checkDate(params[:birthday])
    @msg = "Edit failed! Please enter the correct birthday format!"
    @students = Student.all
    @title = "Students"
    return erb :students
  end

  stu = Student.all(:student_id => params[:id]).first
  stu.firstname = params[:firstname]
  stu.lastname = params[:lastname]
  stu.birthday = params[:birthday] # 2010-05-28T15:36:56.200
  stu.address = params[:address]
  stu.save
  redirect '/students'
end

#delete a student
post '/delete_stu' do
  # check if user login
  if !session[:admin]
    redirect '/'
  end

  stu = Student.all(:student_id => params[:id])
  stu.destroy

  redirect '/students'
end

# video page
get '/video' do
  @title = "Video"
  erb :video
end

# for logout
get '/logout' do
  session.clear
  settings.status = "/"
  redirect '/'
end

def checkDate(date) 
  if(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/.match(date) == nil)
    return false
  else
    return true
  end
end