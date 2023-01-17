require "spec_helper"
require "rack/test"
require_relative "../../app"

describe "MakersBnB" do
  include Rack::Test::Methods
  let(:app) { MakersBnB.new }

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
      post("/login")
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
end
