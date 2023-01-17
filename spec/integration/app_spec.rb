
require "rack/test"
require_relative "../../app"

describe "MakersBnB" do
  include Rack::Test::Methods
  let(:app) { MakersBnB.new }
  
  def check200
    expect(@response.status).to eq(200)
  end

  context "GET /" do
    it "returns homepage with status 200" do
      response = get("/")
      expect(response.status).to eq 200
    end

    it "returns list all properties" do
      response = get("/")
      expect(response.body).to include "Shispare"
      expect(response.body).to include "83"
    end

    xit "has log in button if logged out" do
      response = get("/")
      expect(response.body).to include '<input type="email" name="email" />'
      expect(response.body).to include '<input type="password" name="password" />'
      expect(response.body).to include '<input type="submit" value="Login" />'
    end

    xit "has logout button if logged in" do
      post("/log_in")
      response = get("/")
      expect(response.body).to include '<input type="submit" value="Logout" />'
    end

    xit "has a signup button if logged out" do
      response = get("/")
      expect(response.body).to include ('href="/sign-up')
    end

    xit "has a link to view bookings" do
      response = get("/")
      expect(response.body).to include ('href="/view-bookings')
    end
  end

  context 'booking page tests' do
    it "returns homepage with status 200" do
      response = get("/1")
      expect(response.status).to eq 200
    end

    it "contains the property information" do
      response = get("/1")
      expect(response.body).to include ("K1")
      expect(response.body).to include ("Chuck Norris doesn't delete files, he blows them away.")
      expect(response.body).to include ("93")
      expect(response.body).to include ("2023-03-05")
      expect(response.body).to include ("2023-05-14")
      expect(response.body).to include ('<input type="date" name="start_date" />')
      expect(response.body).to include ('<input type="date" name="end_date" />')
    end
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
