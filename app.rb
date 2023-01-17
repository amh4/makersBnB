# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "bcrypt"
require_relative "lib/booking"
require_relative "lib/property"
require_relative "lib/user"

class MakersBnB < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    @properties = Property.all
    return erb(:homepage)
  end

  get '/log_in' do
    return erb(:log_in)
  end

  get '/sign_up' do
    return erb(:sign_up)
  end

  get '/your_bookings' do
    return erb(:your_bookings)
  end

  get '/:id' do
    @property = Property.find(params[:id])
    return erb(:book_a_space)
  end
end
