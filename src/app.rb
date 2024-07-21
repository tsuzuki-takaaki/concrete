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
MYSQL_SEED_FILE_PATH = File.expand_path("../../sql/mysql/seed.sql", __FILE__)

post '/mysql/initialize' do
  out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{MYSQL_SCHEMA_FILE_PATH}")
  unless status.success?
    return "Failed to initialize"
  end

  out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{MYSQL_SEED_FILE_PATH }")
  unless status.success?
    return "Failed to seed"
  end
  return nil
end

get '/mysql/show-databases' do
  result = mysql_client.query("SHOW DATABASES;")
  json result.to_a
end

get '/mysql/users' do
  result = mysql_client.query("SELECT * FROM user;")
  json result.to_a
end

get '/mysql/user/:id' do
  id = params[:id]

  prepared_statement = mysql_client.prepare("SELECT * FROM user where id = ?;")
  result = prepared_statement.execute(id).first
  json result
end

get '/mysql/posts' do
  result = mysql_client.query("SELECT * FROM post;")
  json result.to_a
end

get '/mysql/user_post' do
  # Not include post.id if you select * from JOIN TABLE
  # Because conflict with user.id(If you want include you can use AS statement)
  result = mysql_client.query("SELECT * FROM user u JOIN post p ON u.id = p.user_id;")
  json result.to_a
end

get '/mysql/user_post_not_aster' do
  result = mysql_client.query("SELECT u.id, u.name, p.id AS post_id, p.title FROM user u JOIN post p ON u.id = p.user_id;")
  json result.to_a
end

get '/mysql/post_user' do
  # Not include user.id if you select * from JOIN TABLE
  # Because conflict with post.id(If you want include you can use AS statement)
  result = mysql_client.query("SELECT * FROM post p JOIN user u ON u.id = p.user_id;")
  json result.to_a
end

# ---------- postgresql ----------
get '/postgre/users' do
end

# ---------- sqlite ----------
get '/sqlite/users' do
end
