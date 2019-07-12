require "sinatra"
require "sinatra/activerecord"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./database.sqlite3")
#require 'active_record'
#ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])


def subscribe_email(recipient)
  Newsletter.signup(recipient).deliver_now
end

enable :sessions

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

get "/" do
  erb :home
end

get "/login" do
  if session[:user_id]
    redirect "/blogposts"
  else
    erb :'users/login'
  end
end

post "/login" do
  password = params['password']
  user = User.find_by(username: params['username'])
  if user
   if user.password == password
     p "User authenticated successfully"
     session[:user] = user
     redirect "/blogposts"
   else
     p "Invalid username or password"
     redirect "/incorrect"
   end
  end
  erb :'users/login'
end

get "/incorrect" do
  erb :'users/incorrect'
end

post '/logout' do
  session.clear
  p "user logged out successfully"
  redirect "/"
end

get "/signup" do
  subscribe_email(params[:email]) if params[:email]
  @user = User.new
  if session[:user]
    redirect "/"
  else
    erb :'users/signup'
  end
end

post '/signup' do
  @user = User.new(params)
  if @user.save
    p "#{@user.first_name} was saved to the database"
    redirect "/thanks"
  end
end

get "/thanks" do
  erb :'users/thanks'
end

get "/blogposts" do
  if session[:user]
    @post = Post.last(20)
  else
    redirect "/"
  end
  erb :'users/blogposts'
end

post "/create_posts" do
  posts = Post.new(title: params[:title], content: params[:content], image_url: params[:image_url], user_id: session[:user].id)
  posts.save
  redirect "/blogposts"
end

get "/account" do
  erb :'users/account'
end

get "/deletepost" do
  redirect "/blogposts"
end

post "/deletepost" do
  delete_post = Post.find(params[:id])
  delete_post.destroy
  redirect "/blogposts"
end

get "/deleteuser" do
  redirect "/"
end

post "/deleteuser" do
  @user = User.find(session[:user].id)
  if @user
    if (@user.id == session[:user].id)
      @user = User.find(session[:user].id).destroy
      @user.destroy
      session[:user] = nil
      redirect "/"
    end
  end
end
