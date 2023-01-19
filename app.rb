# # frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "bcrypt"
require "simple_calendar"
require "date"
require_relative "lib/booking"
require_relative "lib/property"
require_relative "lib/user"
require_relative "lib/availability"

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

  get "/sign_up" do
    return erb(:sign_up)
  end

  post "/approve-reject/:id&:bool" do
    if params[:bool] == "true"
      booking = Booking.find(params[:id].to_i)
      booking.responded = true
      booking.save
    else
      booking = Booking.find(params[:id].to_i)
      booking.responded = false
      booking.save
    end
  end

  get "/bookings" do
    if session[:user_id].nil?
      return ""
    else
      @trips = Booking.joins(:property).select("bookings.*, properties.*").where("user_id" => session[:user_id])
      erb(:bookings)
    end
  end

  get "/log-out" do
    session.clear
    redirect "/"
  end

  get "/add-a-space" do
    return erb(:add_a_space) if logged_in
  end

  post "/add-a-space" do
    if logged_in
      property = Property.create(user_id: session[:user_id], title: params[:title], address: params[:address], description: params[:description], daily_rate: params[:daily_rate])
      Avail.create(property_id: property.id, first_available: params[:first_available], last_available: params[:last_available])
      redirect back
    else
      redirect ("/")
    end
  end

  get "/account" do
    @requests = Booking.joins(:property).select("bookings.*, properties.*").where(["properties.user_id =? and bookings.responded =?", session[:user_id], false])
    return erb(:account_page)
  end

  post "/bookings" do
    return login_fail unless logged_in
    availabilities = Avail.where("property_id = ?", params[:property_id])
    availabilities.each do |availability|
      if compatible(availability)
        Booking.create(user_id: session[:user_id], property_id: params[:property_id],
                       start_date: params[:start_date], end_date: params[:end_date], approved: false)
        availability_updater(availability)
        return erb(:booking_confirmation)
      end
    end
    redirect("/property/#{params[:property_id]}?try_again=true")
  end

  post "/add-availability" do
    return login_fail unless logged_in
    Avail.create(property_id: property.id, first_available: params[:first_available], last_available: params[:last_available])
    redirect back
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
    @try_again = params[:try_again]
    @property = Property.find(params[:id])
    @dates = Avail.where("property_id = ?", params[:id])

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

  def availability_updater(date)
    if params[:start_date].to_date > date.first_available && params[:end_date].to_date < date.last_available
      Avail.create(property_id: params[:property_id], first_available: date.first_available, last_available: params[:start_date].to_date.prev_day)
      Avail.create(property_id: params[:property_id], first_available: params[:end_date].to_date.next_day, last_available: date.last_available)
    elsif params[:start_date].to_date == date.first_available && params[:end_date].to_date == date.last_available
    elsif params[:start_date].to_date == date.first_available
      Avail.create(property_id: params[:property_id], first_available: date.first_available, last_available: params[:end_date].to_date.next_day)
    elsif params[:end_date].to_date == date.last_available
      Avail.create(property_id: params[:property_id], first_available: date.first_available, last_available: params[:start_date].to_date.prev_day)
    end
    Avail.find(date.id).destroy
  end

  def compatible(availability)
    params[:start_date].to_date >= availability.first_available && params[:end_date].to_date <= availability.last_available
  end
end
