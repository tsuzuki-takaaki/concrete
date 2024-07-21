require "mysql2"
require "open3"

MYSQL_HOST = ENV["MYSQL_HOST"]
MYSQL_DATABASE = ENV["MYSQL_DATABASE"]
MYSQL_USER = ENV["MYSQL_USER"]
MYSQL_PASSWORD = ENV["MYSQL_PASSWORD"]

# TODO: Create connection pool
def client
  Mysql2::Client.new(
    :host => MYSQL_HOST,
    :database => MYSQL_DATABASE,
    :username => MYSQL_USER,
    :password => MYSQL_PASSWORD
  )
end

# ----------
# Mysql2::Result(returned from issuing a #query on the connection. It includes Enumerable.)
# Not Collection but Iterator
# to_a -> [{"COLUMN_NAME"=>"VALUE"}, ...]
# ----------

SCHEMA_FILE_PATH = File.expand_path("../../../sql/mysql/schema.sql", __FILE__)
SEED_FILE_PATH = File.expand_path("../../../sql/mysql/seed.sql", __FILE__)
def mysql_initialize
  out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{SCHEMA_FILE_PATH}")
  unless status.success?
    puts "Failed to initialize"
    exit
  end

  out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{SEED_FILE_PATH }")
  unless status.success?
    puts "Failed to initialize"
    exit
  end

  return nil
end

# ---------- show databases
#  mysql> show databases;
#  +--------------------+
#  | Database           |
#  +--------------------+
#  | concrete           |
#  | information_schema |
#  | performance_schema |
#  +--------------------+
#  3 rows in set (0.01 sec)
ShowDatabaseRow = Struct.new(:Database, keyword_init: true)
def show_databases
  # @Mysql2::Result
  result = client.query("SHOW DATABASES;")
  result.each do |row|
    sdb = ShowDatabaseRow.new(row)
    puts "As custom struct: #{sdb}"
  end
  puts "As collection array: #{result.to_a}"
end

# ---------- select user
# mysql> select * from user;
# +----+---------------+---------------------+
# | id | name          | email               |
# +----+---------------+---------------------+
# |  1 | Alice Johnson | alice@example.com   |
# |  2 | Bob Smith     | bob@example.com     |
# ...
UserRow = Struct.new(:id, :name, :email, keyword_init: true)
def select_users
  result = client.query("SELECT * FROM user;")
  result.each do |row|
    user = UserRow.new(row)
    puts "As custom struct: #{user}"
  end
  puts "As collection array: #{result.to_a}"
end

mysql_initialize
show_databases
select_users
