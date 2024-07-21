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

# ---------- SHOW databases;
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

# ---------- SELECT * FROM user;
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

def select_a_user(id:)
  prepared_statement = client.prepare("SELECT * FROM user where id = ?;")
  result = prepared_statement.execute(id).first
  user = UserRow.new(result)
  puts "As custom struct: #{user}"
  puts "First element of result: #{result}"
end

# ---------- SELECT * FROM post;
# mysql> select * from post;
# +----+------------------+----------------------------------------------+---------+
# | id | title            | content                                      | user_id |
# +----+------------------+----------------------------------------------+---------+
# |  1 | First Post       | This is the content of the first post.       |       1 |
# |  2 | Second Post      | This is the content of the second post.      |       2 |
# ...
PostRow = Struct.new(:id, :title, :content, :user_id, keyword_init: true)
def select_posts
  result = client.query("SELECT * FROM post;")

  result.each do |row|
    post = PostRow.new(row)
    puts "As custom struct: #{post}"
  end
  puts "As collection array: #{result.to_a}"
end

# ---------- SELECT * FROM user u JOIN post p ON p.user_id = u.id;
# mysql> select * from user u join post p on p.user_id = u.id;
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# | id | name          | email               | id | title            | content                                      | user_id |
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# |  1 | Alice Johnson | alice@example.com   |  1 | First Post       | This is the content of the first post.       |       1 |
# |  1 | Alice Johnson | alice@example.com   | 11 | Eleventh Post    | This is the content of the eleventh post.    |       1 |
# |  2 | Bob Smith     | bob@example.com     |  2 | Second Post      | This is the content of the second post.      |       2 |
# |  2 | Bob Smith     | bob@example.com     | 12 | Twelfth Post     | This is the content of the twelfth post.     |       2 |
# ...
UserPostRow = Struct.new(:id, :name, :email, :title, :content, :user_id, keyword_init: true)
def select_user_post
  result = client.query("SELECT * FROM user u join post p on u.id = p.user_id")

  result.each do |row|
    # See join table columns(Not include post.id if you select *)
    # Because conflict with user.id(If you want include you can use AS statement)
    # @row: {"id"=>?, "name"=>?, "email"=>?, "title"=>?, "content"=>?, "user_id"=>?}
    user_post = UserPostRow.new(row)
    puts "As custom struct: #{user_post}"
  end
  puts "As collection array: #{result.to_a}"
end

UserPostNotAsterRow = Struct.new(:id, :name, :post_id, :title, :content)
def select_user_post_not_aster
  result = client.query("SELECT u.id, u.name, p.id as post_id, p.title, p.content FROM user u join post p on u.id = p.user_id")

  # result depends on your select column
  result.each do |row|
    user_post_not_aster = UserPostNotAsterRow.new(row)
    puts "As custom struct: #{user_post_not_aster}"
  end
  puts "As collection array: #{result.to_a}"
end

# ---------- SELECT * FROM post p JOIN user u ON p.user_id = u.id;
# mysql> select * from post p join user u on p.user_id = u.id;
# +----+------------------+----------------------------------------------+---------+----+---------------+---------------------+
# | id | title            | content                                      | user_id | id | name          | email               |
# +----+------------------+----------------------------------------------+---------+----+---------------+---------------------+
# |  1 | First Post       | This is the content of the first post.       |       1 |  1 | Alice Johnson | alice@example.com   |
# | 11 | Eleventh Post    | This is the content of the eleventh post.    |       1 |  1 | Alice Johnson | alice@example.com   |
# |  2 | Second Post      | This is the content of the second post.      |       2 |  2 | Bob Smith     | bob@example.com     |
# ...
PostUserRow = Struct.new(:id, :title, :content, :user_id, :name, :email, keyword_init: true)
def select_post_user
  result = client.query("SELECT * FROM post p JOIN user u ON p.user_id = u.id;")

  result.each do |row|
    # See join table columns(Not include user.id if you select *)
    # @row: {"id"=>?, "title"=>?, "content"=>?, "user_id"=>?, "name"=>?, "email"=>?}
    post_user = PostUserRow.new(row)
    puts "As custom struct: #{post_user}"
  end
  puts "As collection array: #{result.to_a}"
end

# ---------- COLUMN(Order is not guaranteed) ----------
# mysql> select * from user u join post p on p.user_id = u.id;
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# | id | name          | email               | id | title            | content                                      | user_id |
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# |  1 | Alice Johnson | alice@example.com   |  1 | First Post       | This is the content of the first post.       |       1 |
# |  1 | Alice Johnson | alice@example.com   | 11 | Eleventh Post    | This is the content of the eleventh post.    |       1 |
# |  2 | Bob Smith     | bob@example.com     |  2 | Second Post      | This is the content of the second post.      |       2 |
# |  2 | Bob Smith     | bob@example.com     | 12 | Twelfth Post     | This is the content of the twelfth post.     |       2 |
# |  3 | Charlie Brown | charlie@example.com |  3 | Third Post       | This is the content of the third post.       |       3 |
# |  3 | Charlie Brown | charlie@example.com | 13 | Thirteenth Post  | This is the content of the thirteenth post.  |       3 |
# |  4 | David Wilson  | david@example.com   |  4 | Fourth Post      | This is the content of the fourth post.      |       4 |
# |  4 | David Wilson  | david@example.com   | 14 | Fourteenth Post  | This is the content of the fourteenth post.  |       4 |
# |  5 | Eve Davis     | eve@example.com     |  5 | Fifth Post       | This is the content of the fifth post.       |       5 |
# |  5 | Eve Davis     | eve@example.com     | 15 | Fifteenth Post   | This is the content of the fifteenth post.   |       5 |
# |  6 | Frank Miller  | frank@example.com   |  6 | Sixth Post       | This is the content of the sixth post.       |       6 |
# |  6 | Frank Miller  | frank@example.com   | 16 | Sixteenth Post   | This is the content of the sixteenth post.   |       6 |
# |  7 | Grace Lee     | grace@example.com   |  7 | Seventh Post     | This is the content of the seventh post.     |       7 |
# |  7 | Grace Lee     | grace@example.com   | 17 | Seventeenth Post | This is the content of the seventeenth post. |       7 |
# |  8 | Hank Moore    | hank@example.com    |  8 | Eighth Post      | This is the content of the eighth post.      |       8 |
# |  8 | Hank Moore    | hank@example.com    | 18 | Eighteenth Post  | This is the content of the eighteenth post.  |       8 |
# |  9 | Ivy Clark     | ivy@example.com     |  9 | Ninth Post       | This is the content of the ninth post.       |       9 |
# |  9 | Ivy Clark     | ivy@example.com     | 19 | Nineteenth Post  | This is the content of the nineteenth post.  |       9 |
# | 10 | Jack White    | jack@example.com    | 10 | Tenth Post       | This is the content of the tenth post.       |      10 |
# | 10 | Jack White    | jack@example.com    | 20 | Twentieth Post   | This is the content of the twentieth post.   |      10 |
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# 20 rows in set (0.01 sec)
#
# mysql> select * from user u join post p on p.user_id = u.id;
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# | id | name          | email               | id | title            | content                                      | user_id |
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# |  1 | Alice Johnson | alice@example.com   |  1 | First Post       | This is the content of the first post.       |       1 |
# |  2 | Bob Smith     | bob@example.com     |  2 | Second Post      | This is the content of the second post.      |       2 |
# |  3 | Charlie Brown | charlie@example.com |  3 | Third Post       | This is the content of the third post.       |       3 |
# |  4 | David Wilson  | david@example.com   |  4 | Fourth Post      | This is the content of the fourth post.      |       4 |
# |  5 | Eve Davis     | eve@example.com     |  5 | Fifth Post       | This is the content of the fifth post.       |       5 |
# |  6 | Frank Miller  | frank@example.com   |  6 | Sixth Post       | This is the content of the sixth post.       |       6 |
# |  7 | Grace Lee     | grace@example.com   |  7 | Seventh Post     | This is the content of the seventh post.     |       7 |
# |  8 | Hank Moore    | hank@example.com    |  8 | Eighth Post      | This is the content of the eighth post.      |       8 |
# |  9 | Ivy Clark     | ivy@example.com     |  9 | Ninth Post       | This is the content of the ninth post.       |       9 |
# | 10 | Jack White    | jack@example.com    | 10 | Tenth Post       | This is the content of the tenth post.       |      10 |
# |  1 | Alice Johnson | alice@example.com   | 11 | Eleventh Post    | This is the content of the eleventh post.    |       1 |
# |  2 | Bob Smith     | bob@example.com     | 12 | Twelfth Post     | This is the content of the twelfth post.     |       2 |
# |  3 | Charlie Brown | charlie@example.com | 13 | Thirteenth Post  | This is the content of the thirteenth post.  |       3 |
# |  4 | David Wilson  | david@example.com   | 14 | Fourteenth Post  | This is the content of the fourteenth post.  |       4 |
# |  5 | Eve Davis     | eve@example.com     | 15 | Fifteenth Post   | This is the content of the fifteenth post.   |       5 |
# |  6 | Frank Miller  | frank@example.com   | 16 | Sixteenth Post   | This is the content of the sixteenth post.   |       6 |
# |  7 | Grace Lee     | grace@example.com   | 17 | Seventeenth Post | This is the content of the seventeenth post. |       7 |
# |  8 | Hank Moore    | hank@example.com    | 18 | Eighteenth Post  | This is the content of the eighteenth post.  |       8 |
# |  9 | Ivy Clark     | ivy@example.com     | 19 | Nineteenth Post  | This is the content of the nineteenth post.  |       9 |
# | 10 | Jack White    | jack@example.com    | 20 | Twentieth Post   | This is the content of the twentieth post.   |      10 |
# +----+---------------+---------------------+----+------------------+----------------------------------------------+---------+
# 20 rows in set (0.00 sec)


mysql_initialize
# show_databases
# select_users
# select_posts
# select_post_user
select_a_user(id: 2)
