require "mysql2"
require "sinatra"
set :bind, '0.0.0.0'

mysql_client = Mysql2::Client.new(
  :host => ENV["MYSQL_HOST"],
  :database => ENV["MYSQL_DATABASE"],
  :username => ENV["MYSQL_USER"],
  :password => ENV["MYSQL_PASSWORD"]
)

get '/' do
  return "Hello world!\n"
end

get '/mysql/users' do
end

get '/postgre/users' do
end

get '/sqlite/users' do
end
