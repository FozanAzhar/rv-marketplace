require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "associations" do
    it "belongs to a user and rv_listing" do
      booking = create(:booking)
      expect(booking.user).to be_present
      expect(booking.rv_listing).to be_present
    end
  end

  describe "validations" do
    it "is invalid without start_date" do
      expect(build(:booking, start_date: nil)).not_to be_valid
    end

    it "is invalid without end_date" do
      expect(build(:booking, end_date: nil)).not_to be_valid
    end

    it "is invalid with an unknown status" do
      expect(build(:booking, status: "cancelled")).not_to be_valid
    end

    it "requires end_date to be after start_date" do
      booking = build(:booking, start_date: Date.current + 7.days, end_date: Date.current + 1.day)
      expect(booking).not_to be_valid
      expect(booking.errors[:end_date]).to include("must be after start date")
    end

    it "defaults status to pending" do
      booking = create(:booking)
      expect(booking.status).to eq("pending")
    end
  end
end
