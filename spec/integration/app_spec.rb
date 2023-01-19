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

  context "booking page tests" do
    it "contains the property information" do
      @response = get("/property/1")
      expect(@response.body).to include "K12"
      expect(@response.body).to include ("Chuck Norris doesn't delete files, he blows them away.")
      expect(@response.body).to include ("93")
      expect(@response.body).to include ("2023-03-05")
      expect(@response.body).to include ("2023-05-14")
      expect(@response.body).to include ('<input type="date" name="start_date" />')
      expect(@response.body).to include ('<input type="date" name="end_date" />')
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
#### TEST IS DEPENDENT ON OTHER BRANCH. METHOD DOES WORK IN LOCAL HOST
  # context "get /bookings" do
  # end

  context "GET /account" do
    it "returns a page containing your bookings that need to be approved" do
      post("/log-in?email=adam.hoar@icloud.com&password=password")
      @response = get('/account')
      expect(@response.body).to include('Baltoro Kangri')
    end
  end
end
