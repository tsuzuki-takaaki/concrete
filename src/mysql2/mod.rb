require "mysql2"
require "open3"

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

# ----------
# Mysql2::Result(returned from issuing a #query on the connection. It includes Enumerable.)
# Not Collection but Iterator
# to_a -> [{"COLUMN_NAME"=>"VALUE"}, ...]

# ---------- show databases
#  SHOW DATABASES;
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
# return @Mysql2::Result
mysql_client.query("SHOW DATABASES;").each do |row|
  sdb = ShowDatabaseRow.new(row)
  puts sdb
end

# ---------- (create|drop) schema
SCHEMA_FILE_PATH = File.expand_path("../../../sql/mysql/schema.sql", __FILE__)
out, status = Open3.capture2("mysql -u#{MYSQL_USER} -p#{MYSQL_PASSWORD} -h#{MYSQL_HOST} #{MYSQL_DATABASE} < #{SCHEMA_FILE_PATH}")
puts out, status
