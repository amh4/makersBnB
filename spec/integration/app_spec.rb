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
        '<input type="text" name="email">',
        '<input type="text" name="password">'
      )
      check200
    end
  end  

  context "POST /log_in" do
    it "if valid credentials, returns your bookings page" do
      @response = post('/log_in',
      email: 'walker@homenick-beer.co',
      password: "NKhqEmiBWNJXpq"
    )
      check200
      expect(@response.body).to include(
        '<h1>Your Bookings</h1>')
        # "Himalchuli",
        # "Mount Everest")
      
    end

    it "if invalid credentials, returns login_error page" do
      @response = post('/log_in',
        email: 'walker@homenick-beer.co',
        password: "NKhqEmiBWNJXp"
      )
      check200
      expect(@response.body).to include("<h1>Log In Error</h1>")
    end


  end 
  
  context "GET /bookings when logged in" do
    it "returns the page of user bookings" do
      post('/log_in',
        email: 'walker@homenick-beer.co',
        password: "NKhqEmiBWNJXpq"
      )
      @response = get("/bookings")
      check200
      expect(@response.body).to include(
        '<h1>Your Bookings</h1>',
        "Himalchuli",
        "Mount Everest")
    end
  end

end
