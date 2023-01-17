# frozen_string_literal: true
require_relative '../../app'
require 'rack/test'


describe MakersBnB do
  include Rack::Test::Methods

  let(:app) { MakersBnB.new }

  def check200
    expect(@response.status).to eq(200)
  end

  context "GET /log_in" do
    it "returns the html form to log in" do
      @response = get('/log_in')
      expect(@response.body).to include('<h1>Log In to MakersBnB</h1>',
        '<input type="text name="email">',
        '<input type="text name="password">'
      )
      check200
    end
  end  

  context "POST /log_in" do
    it "returns your bookings page if successful " do
      @response = post('/log_in',
      email: 'claretha@walter-dach.name',
      password: 'KMWBjqEiPNo'
      )
      expect(@response.body).to include('<h1>Your Bookings</h1>'
      )
      check200
    end
  end  
end



