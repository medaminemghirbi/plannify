class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :lockable, :trackable

  belongs_to :gym, optional: true

  has_many :coach_gyms, foreign_key: :user_id, dependent: :destroy
  has_many :coached_gyms, through: :coach_gyms, source: :gym
  has_many :client_gyms, foreign_key: :user_id, dependent: :destroy
  has_many :client_in_gyms, through: :client_gyms, source: :gym
  has_many :training_groups_coached, foreign_key: :coach_id, class_name: "TrainingGroup", inverse_of: :coach, dependent: :restrict_with_error
  has_many :managed_gyms, class_name: "Gym", foreign_key: :admin_id, inverse_of: :admin, dependent: :nullify
  has_many :attendances, foreign_key: :client_id, dependent: :destroy
  has_many :payments, foreign_key: :client_id, dependent: :destroy
  has_many :generated_payment_receipts, class_name: "PaymentReceipt", foreign_key: :generated_by_id, dependent: :restrict_with_error, inverse_of: :generated_by
  has_many :group_memberships, foreign_key: :client_id, dependent: :destroy
  has_many :groups, through: :group_memberships, source: :training_group
  ROLES = %w[superadmin admin coach client].freeze
  NO_AUTH_ROLES = %w[coach client].freeze

  validates :full_name, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  def password_required?
    new_record? && !NO_AUTH_ROLES.include?(role)
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
