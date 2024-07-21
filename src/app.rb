require "mysql2"
require "sinatra"
require "sinatra/json"
require "open3"
set :bind, '0.0.0.0'

MYSQL_HOST = ENV["MYSQL_HOST"]
MYSQL_DATABASE = ENV["MYSQL_DATABASE"]
MYSQL_USER = ENV["MYSQL_USER"]
MYSQL_PASSWORD = ENV["MYSQL_PASSWORD"]

mysql_client = Mysql2::Client.new(
  :host => MYSQL_HOST,
  :database => MYSQL_DATABASE,
  :username => MYSQL_USER,
  :password => MYSQL_PASSWORD
)

get '/' do
  return "Hello world!\n"
end

# ---------- mysql ----------
MYSQL_SCHEMA_FILE_PATH = File.expand_path("../../sql/mysql/schema.sql", __FILE__)

post '/mysql/initialize' do
  out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{MYSQL_SCHEMA_FILE_PATH}")
  unless status.success?
    "Failed to initialize"
  end
  nil
end

get '/mysql/show-databases' do
  result = mysql_client.query("SHOW DATABASES;")
  json result.to_a
end

get '/mysql/users' do
end

get '/postgre/users' do
end

get '/sqlite/users' do
end