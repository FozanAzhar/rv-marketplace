class Booking < ApplicationRecord
  # Owner confirms or rejects via PATCH /bookings/:id/confirm|reject
  STATUSES = %w[pending confirmed rejected].freeze

  belongs_to :user
  belongs_to :rv_listing

  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date > start_date

    errors.add(:end_date, "must be after start date")
  end
end
