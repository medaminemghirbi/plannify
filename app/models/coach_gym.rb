class CoachGym < ApplicationRecord
  belongs_to :user, inverse_of: :coach_gyms
  belongs_to :gym, inverse_of: :coach_gyms

  validates :user_id, :gym_id, presence: true
  validate :user_must_be_coach

  private

  def user_must_be_coach
    return if user&.coach?

    errors.add(:user, "must have coach role")
  end
end
