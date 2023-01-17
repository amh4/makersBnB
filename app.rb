# # frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative 'lib/booking'
require_relative 'lib/property'
require_relative 'lib/user'

class MakersBnB < Sinatra::Base
  enable :sessions
  configure :development do
    register Sinatra::Reloader
  end

  get '/log_in' do
    return erb(:log_in)
  end

  get "/bookings" do
    user_id = session[:user_id]
    @bookings = Booking.find_by(user_id: user_id)
    erb(:bookings)
  end

  post '/log_in' do
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)
    if user.authenticate(password)
      session[:user_id] = user.id
      return erb(:bookings)
    else
      return erb(:log_in_error)
    end
  end
end
