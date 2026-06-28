require "rails_helper"

RSpec.describe RvListing, type: :model do
  describe "associations" do
    it "belongs to a user" do
      listing = create(:rv_listing)
      expect(listing.user).to be_present
    end

    it "has many bookings" do
      listing = create(:rv_listing)
      booking = create(:booking, rv_listing: listing)
      expect(listing.bookings).to include(booking)
    end

    it "has many messages" do
      listing = create(:rv_listing)
      message = create(:message, rv_listing: listing)
      expect(listing.messages).to include(message)
    end
  end

  describe "validations" do
    it "is invalid without a title" do
      expect(build(:rv_listing, title: nil)).not_to be_valid
    end

    it "is invalid without a description" do
      expect(build(:rv_listing, description: nil)).not_to be_valid
    end

    it "is invalid without a location" do
      expect(build(:rv_listing, location: nil)).not_to be_valid
    end

    it "is invalid without a price_per_day" do
      expect(build(:rv_listing, price_per_day: nil)).not_to be_valid
    end

    it "is invalid with a non-positive price_per_day" do
      expect(build(:rv_listing, price_per_day: 0)).not_to be_valid
      expect(build(:rv_listing, price_per_day: -10)).not_to be_valid
    end
  end
end
