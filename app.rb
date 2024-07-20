require "sinatra"
set :bind, '0.0.0.0'

get '/' do
  return "Hello world!\n"
end

get '/mysql/users' do
end

get '/postgre/users' do
end

get '/sqlite/users' do
end
