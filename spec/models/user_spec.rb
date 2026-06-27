require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "has many rv_listings" do
      user = create(:user)
      listing = create(:rv_listing, user: user)
      expect(user.rv_listings).to include(listing)
    end

    it "has many bookings" do
      user = create(:user)
      booking = create(:booking, user: user)
      expect(user.bookings).to include(booking)
    end

    it "has many messages" do
      user = create(:user)
      message = create(:message, user: user)
      expect(user.messages).to include(message)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      expect(build(:user, name: nil)).not_to be_valid
    end

    it "is invalid without an email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "dup@example.com")
      expect(build(:user, email: "dup@example.com")).not_to be_valid
    end
  end

  describe "password" do
    it "authenticates with the correct password" do
      user = create(:user, password: "secret123", password_confirmation: "secret123")
      expect(user.authenticate("secret123")).to eq(user)
    end

    it "does not authenticate with the wrong password" do
      user = create(:user)
      expect(user.authenticate("wrong")).to be_falsey
    end
  end
end
