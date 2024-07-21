require "mysql2"

mysql_client = Mysql2::Client.new(
  :host => ENV["MYSQL_HOST"],
  :database => ENV["MYSQL_DATABASE"],
  :username => ENV["MYSQL_USER"],
  :password => ENV["MYSQL_PASSWORD"]
)

# ----------
# Mysql2::Result(returned from issuing a #query on the connection. It includes Enumerable.)
# Not Collection but Iterator
# to_a -> [{"COLUMN_NAME"=>"VALUE"}, ...]

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
# result: Mysql2::Result
result = mysql_client.query("SHOW DATABASES;")
result.each do |row|
  sdb = ShowDatabaseRow.new(row)
  puts sdb
end
