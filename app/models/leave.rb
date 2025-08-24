class Leave < ApplicationRecord
  LEAVE_TYPES = [
    "academic",
    "vacations",
    "medical",
    "maternity",
    "paternity",
    "compensatory",
    "special",
    "administrative",
    "training"
  ].freeze

  LEAVE_STATES = [
    "pending",
    "approved",
    "rejected",
    "cancelled"
  ].freeze

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :type, presence: true, inclusion: { in: LEAVE_TYPES }
  validates :state, presence: true, inclusion: { in: LEAVE_STATES }
  validate :end_date_greater_than_start_date

  private

  def end_date_greater_than_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be greater than or equal to start date")
    end
  end
end
