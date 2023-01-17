require "spec_helper"
require "rack/test"
require_relative "../../app"

describe "MakersBnB" do
  include Rack::Test::Methods
  let(:app) { MakersBnB.new }

  context "GET /" do
    it "returns homepage with status 200" do
      response = get("/")
      expect(response.body).to eq 200
    end

    it "returns list all properties" do
      response = get("/")
      expect(response.body).to include "Property title"
      expect(response.body).to include "Price per night"
    end

    it "has log in button if logged out" do
      response = get("/")
      expect(response.body).to include '<input type="email" name="email" />'
      expect(response.body).to include '<input type="password" name="password" />'
      expect(response.body).to include '<input type="submit" value="Login" />'
    end

    xit "has logout button if logged in" do
      post("/login")
      response = get("/")
      expect(response.body).to include '<input type="submit" value="Logout" />'
    end

    it "has a signup button if logged out" do
      response = get("/")
      expect(response.body).to include ('href="/sign-up')
    end

    it "has views bookings button" do
      response = get("/")
      expect(response.body).to include ('href="/view-bookings')
    end
  end
end
