class GroupMembership < ApplicationRecord
  belongs_to :client, class_name: "User", foreign_key: :client_id, inverse_of: :group_memberships
  belongs_to :training_group

  validates :client_id, :training_group_id, presence: true
  validates :client_id, uniqueness: { scope: :training_group_id, message: "can only join a group once" }

  before_create :set_joined_at

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end
end
