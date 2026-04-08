class Gym < ApplicationRecord
  CURRENCIES = %w[USD TND EUR].freeze

  belongs_to :admin, class_name: "User"

  has_one_attached :logo

  has_many :users, dependent: :nullify
  has_many :coaches, -> { where(role: "coach") }, class_name: "User", inverse_of: :gym
  has_many :clients, -> { where(role: "client") }, class_name: "User", inverse_of: :gym
  has_many :training_groups, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :name, presence: true
  validates :admin_id, uniqueness: true
  validates :currency, inclusion: { in: CURRENCIES }
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
end
