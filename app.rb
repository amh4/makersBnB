# # frozen_string_literal: true



require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "bcrypt"
require "simple_calendar"
require_relative "lib/booking"
require_relative "lib/property"
require_relative "lib/user"

class MakersBnB < Sinatra::Base
  enable :sessions
  configure :development do
    register Sinatra::Reloader
  end

  use Rack::Session::Cookie, :key => "rack.session",
                             :path => "/",
                             :secret => ENV.fetch("SESSION_SECRET") { SecureRandom.hex(20) }

  get "/" do
    @a = logged_in
    @properties = Property.all
    return erb(:homepage)
  end

  get "/log-in" do
    return erb(:log_in)
  end


  get '/sign_up' do
    return erb(:sign_up)
  end


  get "/bookings" do
    if session[:user_id].nil?
      return ""
    else
      @properties = Property.joins(:bookings).select("bookings.*, properties.*").where("user_id" => session[:user_id])
      erb(:bookings)
    end
  end

  post "/bookings" do
    # way to obtain property id is incomplete and we have requested user to input this as temp workaround
    return login_fail unless logged_in
    booking = Booking.create(user_id: session[:user_id], property_id: params[:property_id],
    start_date: params[:start_date], end_date: params[:end_date], approved: false)
  end

  post "/bookings" do
    # way to obtain property id is incomplete and we have requested user to input this as temp workaround

    booking = Booking.create(user_id: session[:user_id], property_id: params[:property_id],
    start_date: params[:start_date], end_date: params[:end_date], approved: false)
    
  end

  post "/log-in" do
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)
    return erb(:log_in_error) if user.nil?
    if user.authenticate(password)
      session[:user_id] = user.id
      return erb(:logged_in)
    else
      status 400
      return erb(:log_in_error)
    end
  end

  get "/sign-up" do
    return erb(:sign_up)
  end

  post "/sign-up" do
    encrypted_password = BCrypt::Password.create(params[:password])
    @user = User.create(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password_digest: encrypted_password)
    if @user.errors.empty?
      return erb(:sign_up_confirmation)
    else
      status 400
      return erb(:sign_up_error)
    end
  end

  get "/property/:id" do
    @property = Property.find(params[:id])
    return erb(:book_a_space)
  end

  private

  def logged_in
    if session[:user_id] == nil
      return false
    else
      return true
    end
  end

  def login_fail
    status 400 
    erb(:log_in_error)
  end
end
