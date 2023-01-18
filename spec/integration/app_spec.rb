require "spec_helper"
require "rack/test"
require_relative "../../app"
require "bcrypt"

describe "MakersBnB" do
  include Rack::Test::Methods
  let(:app) { MakersBnB.new }

  def check200
    expect(@response.status).to eq 200
  end

  def check400
    expect(@response.status).to eq 400
  end

  def sign_up
    post("/sign-up?first_name=orhan&last_name=khanbayov&email=orhan.khanbayov@hotmail.co.uk&password=mypassword")
  end

  def login
    post("/log-in?email=orhan.khanbayov@hotmail.co.uk&password=mypassword")
  end

  context "GET /" do
    it "returns homepage with status 200" do
      @response = get("/")
      check200
      expect(@response.body).to include "MakersBnB"
    end

    it "returns list all properties" do
      @response = get("/")
      expect(@response.body).to include "K12"
      expect(@response.body).to include "93"
    end

    it "has log in button if logged out" do
      @response = get("/")
      expect(@response.body).to include "Click to login"
    end

    it "has logout button if logged in" do
      sign_up
      login
      @response = get("/")
      expect(@response.body).to include "Click to logout"
    end

    it "has a signup button if logged out" do
      @response = get("/")
      expect(@response.body).to include ("Click to sign up")
    end

    it "has a link to view bookings if logged in" do
      sign_up
      login
      @response = get("/")
      expect(@response.body).to include ("Click to view bookings")
    end
  end

  context "GET /log-in" do
    it "returns the html form to log in" do
      @response = get("/log-in")
      check200
      expect(@response.body).to include("<h1>Log In to MakersBnB</h1>")
      expect(@response.body).to include('<input type="text" name="email">')
      expect(@response.body).to include('<input type="password" name="password">')
    end
  end

  context "POST /log-in" do
    it "if valid credentials, returns your bookings page" do
      sign_up
      @response = login
      expect(@response.body).to include "You're logged in to MakersBnB"
    end

    it "if invalid credentials, returns login_error page" do
      @response = post("/log-in",
                       email: "claretha@walter-dach.name",
                       password: "NKhqEmiBWNJXp")
      check400
      expect(@response.body).to include("<h1>Log In Error</h1>")
    end
  end

  context "GET /bookings when logged in" do
    it "returns the page of user bookings" do
      sign_up
      login
      @response = get("/bookings")
      check200
      expect(@response.body).to include "<h1>Your Bookings</h1>"
    end
  end

  context "GET /sign-up" do
    it "returns sign-up page with 200 status" do
      @response = get("/sign-up")
      check200
      expect(@response.body).to include "email"
      expect(@response.body).to include "password"
    end
  end

  context "POST /sign-up" do
    it "creates user entry in database" do
      @response = sign_up
      check200
      expect(@response.body).to include "You're signed up to MakersBnB"
    end

    it "returns an error if email is already in use" do
      sign_up
      @response = sign_up
      check400
      expect(@response.body).to include "Email address already in use."
    end
  end

  context "GET /property/:id" do
    it "gets booking page for property with :id" do
      @response = get("/property/1")
      check200
      expect(@response.body).to include(
        "<head>Book a space</head>",
        "K12",
        "Chuck Norris doesn't delete files, he blows them away."
      )
    end
  end

  context "POST /bookings" do
    it "adds users booking to the bookings table" do
      sign_up
      login
      @response = post('/bookings',
      property_id: 10,
      start_date: '2023-04-01',
      end_date: '2023-04-03',
      approved: false)
      check200
      expect(Booking.last.id).to eq(11)
      expect(Booking.last.property_id).to eq(10)
      expect(Booking.last.start_date.to_s).to eq("2023-04-01")
      expect(Booking.last.end_date.to_s).to eq("2023-04-03")
      expect(Booking.last.approved).to eq(false)
    end
  end

  context "POST /bookings" do
    it "returns logged in error page if user is not signed in" do
      sign_up
      @response = post('/bookings',
      property_id: 10,
      start_date: '2023-04-01',
      end_date: '2023-04-03',
      approved: false)
      check400
      expect(Booking.last.id).to eq(10)
      expect(@response.body).to include ('Log In Error')
    end
  end
end
