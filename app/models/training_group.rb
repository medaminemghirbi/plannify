class TrainingGroup < ApplicationRecord
  belongs_to :gym

  belongs_to :coach, class_name: "User", foreign_key: :coach_id, inverse_of: :training_groups_coached
  has_many :planning_sessions, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :clients, through: :group_memberships, source: :client

  validates :name, presence: true
  validates :coach_id, presence: true
  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true

  def name_with_coach
    coach_name = coach&.full_name || "No coach"
    "#{name} - Coach: #{coach_name}"
  end
end
