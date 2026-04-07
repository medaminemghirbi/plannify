class Attendance < ApplicationRecord
  belongs_to :client, class_name: "User", foreign_key: :client_id, inverse_of: :attendances
  belongs_to :training_group

  STATUSES = %w[present absent].freeze

  validates :date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :client_id, uniqueness: { scope: [:training_group_id, :date], message: "already has attendance for this date and group" }
end
