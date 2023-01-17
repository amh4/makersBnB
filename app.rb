# # frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative 'lib/booking'
require_relative 'lib/property'
require_relative 'lib/user'

class MakersBnB < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  get '/log_in' do
    return erb(:log_in)
  end

  post '/log_in' do
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)
    # binding.irb
    if user.authenticate(password)
      session[:user_id] = user.id
      return erb(:your_bookings)
    else
      return erb(:log_in_error)
    end
  end
end
