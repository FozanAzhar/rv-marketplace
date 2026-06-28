# Communication thread item — tied to a listing and its author (see MessagesController).
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :rv_listing

  validates :content, presence: true
end
