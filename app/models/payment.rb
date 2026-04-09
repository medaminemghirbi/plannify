class Payment < ApplicationRecord
  DURATIONS = [1, 3, 12].freeze
  STATUSES = %w[pending paid overdue].freeze

  belongs_to :client, class_name: "User", foreign_key: :client_id, inverse_of: :payments
  belongs_to :created_by, class_name: "User", optional: true
  has_one :receipt, class_name: "PaymentReceipt", dependent: :destroy, inverse_of: :payment

  validates :amount, numericality: { greater_than: 0 }
  validates :starts_on, presence: true
  validates :duration_months, inclusion: { in: DURATIONS }
  validates :status, inclusion: { in: STATUSES }

  delegate :gym, to: :client

  def ends_on
    starts_on + duration_months.months - 1.day
  end

  def duration_label
    return "1 month" if duration_months == 1
    return "3 months" if duration_months == 3

    "1 year"
  end

  def paid?
    status == "paid"
  end
end
