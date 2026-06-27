require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it "belongs to a user and rv_listing" do
      message = create(:message)
      expect(message.user).to be_present
      expect(message.rv_listing).to be_present
    end
  end

  describe "validations" do
    it "is invalid without content" do
      expect(build(:message, content: nil)).not_to be_valid
    end
  end
end
