class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :lockable, :trackable

  belongs_to :gym, optional: true
  has_many :training_groups_coached, foreign_key: :coach_id, class_name: "TrainingGroup", inverse_of: :coach, dependent: :restrict_with_error
  has_one :managed_gym, class_name: "Gym", foreign_key: :admin_id, inverse_of: :admin, dependent: :destroy
  has_many :attendances, foreign_key: :client_id, dependent: :destroy
  has_many :payments, foreign_key: :client_id, dependent: :destroy
  has_many :generated_payment_receipts, class_name: "PaymentReceipt", foreign_key: :generated_by_id, dependent: :restrict_with_error, inverse_of: :generated_by
  has_many :group_memberships, foreign_key: :client_id, dependent: :destroy
  has_many :groups, through: :group_memberships, source: :training_group
  ROLES = %w[superadmin admin coach client].freeze
  NO_AUTH_ROLES = %w[coach client].freeze

  validates :full_name, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :gym, presence: true, if: :gym_required?
  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  scope :in_gyms, ->(gym_scope) { where(gym_id: gym_scope.select(:id)) }

  def password_required?
    new_record? && !NO_AUTH_ROLES.include?(role)
  end

  def gym_required?
    coach? || client?
  end

  scope :superadmins, -> { where(role: "superadmin") }
  scope :admins, -> { where(role: "admin") }
  scope :coaches, -> { where(role: "coach") }
  scope :clients, -> { where(role: "client") }

  def superadmin?
    role == "superadmin"
  end

  def admin?
    role == "admin"
  end

  def coach?
    role == "coach"
  end

  def client?
    role == "client"
  end
end
