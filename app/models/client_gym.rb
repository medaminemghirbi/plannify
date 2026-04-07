class ClientGym < ApplicationRecord
  belongs_to :user, inverse_of: :client_gyms
  belongs_to :gym, inverse_of: :client_gyms

  validates :user_id, :gym_id, presence: true
  validate :user_must_be_client

  private

  def user_must_be_client
    return if user&.client?

    errors.add(:user, "must have client role")
  end
end
