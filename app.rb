# # frozen_string_literal: true



require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "bcrypt"
require "simple_calendar"
require 'date'
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
      query = "SELECT properties.title, properties.description,
      bookings.start_date, bookings.end_date
      FROM properties JOIN bookings
      ON bookings.user_id=#{session[:user_id]}
      AND bookings.property_id = properties.id"
      @trips = ActiveRecord::Base.connection.execute(query)
      erb(:bookings)
    end
  end

  post "/bookings" do
    # way to obtain property id is incomplete and we have requested user to input this as temp workaround
    return login_fail unless logged_in
    property = Property.find(params[:property_id])
    available_dates = available_pairs(property)
    attempted_pair = [Date.parse(params[:start_date]), Date.parse(params[:end_date])]
    worked = available_dates.any? { |available_pair| lies_within_dates(attempted_pair, available_pair)}
    redirect("/property/#{params[:property_id]}?try_again=true") unless worked
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
    @try_again = params[:try_again]
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

  def available_pairs(property)
    arr = [[property.first_available]]
    query = "SELECT bookings.start_date, bookings.end_date
    FROM properties JOIN bookings
    ON bookings.property_id = #{property.id}
    AND properties.id = #{property.id}
    ORDER BY bookings.start_date ASC"
    bookings= ActiveRecord::Base.connection.execute(query)
    bookings.each do |booking|
      start_date, end_date = Date.parse(booking["start_date"]), Date.parse(booking["end_date"])
      arr[-1] << start_date.yesterday
      arr << [end_date.tomorrow]
    end
    arr[-1] << property.last_available
    arr
  end

  def lies_within_dates(attempted_pair, available_pair)
    attempted_pair[0] >= available_pair[0] && attempted_pair[1] <= available_pair[1]
  end

end
