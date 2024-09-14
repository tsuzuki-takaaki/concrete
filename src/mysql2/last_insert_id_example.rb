require 'mysql2'

MYSQL_HOST = ENV['MYSQL_HOST']
MYSQL_DATABASE = ENV['MYSQL_DATABASE']
MYSQL_USER = ENV['MYSQL_USER']
MYSQL_PASSWORD = ENV['MYSQL_PASSWORD']

mysql_client = Mysql2::Client.new(
  host: MYSQL_HOST,
  database: MYSQL_DATABASE,
  username: MYSQL_USER,
  password: MYSQL_PASSWORD
)

def build_user_insert_statement(name:, email:)
  "INSERT INTO `user` (`name`, `email`) VALUES ('#{name}', '#{email}');"
end

result = mysql_client.query(build_user_insert_statement(name: 'hoge', email: 'fuga'))

puts "result: #{result}"
puts "last_insert_id: #{mysql_client.last_id}"
