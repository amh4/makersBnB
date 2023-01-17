require "spec_helper"
require "rack/test"
require_relative "../../app"

describe "MakersBnB" do
  include Rack::Test::Methods
  let(:app) { MakersBnB.new }

  context "GET /sign-up" do
    it "returns sign-up page with 200 status" do
      response = get("/sign-up")
      expect(response.status).to eq 200
      expect(response.body).to include "email"
      expect(response.body).to include "password"
    end
  end

  context "POST /sign-up" do
    xit "creates user entry in database" do
      response = post("http://localhost:9292/sign-up?first_name=orhan&last_name=khanbayov&email=orhan.khanbayov@hotmail.co.uk&pasword=mypassword")
      expect(response.status).to eq 200
      expect(response.body).to include "You're signed up to MakersBnB"
    end

    xit "returns an error if email is already in use" do
      post("http://localhost:9292/sign-up?first_name=orhan&last_name=khanbayov&email=orhan.khanbayov@hotmail.co.uk&pasword=mypassword")
      response = post("http://localhost:9292/sign-up?first_name=orhan&last_name=khanbayov&email=orhan.khanbayov@hotmail.co.uk&pasword=mypassword")
      expect(response.status).to eq 200
      expect(response.body).to include "Email address already in use."
    end
  end
end
