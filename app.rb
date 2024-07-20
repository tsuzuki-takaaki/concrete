require "mysql2"
require "sinatra"
set :bind, '0.0.0.0'

# TODO: Use env
mysql_client = Mysql2::Client.new(
  :host => "mysql",
  :username => "root",
  :password => "password",
  :database => "concrete"
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
