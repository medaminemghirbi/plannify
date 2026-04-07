class Gym < ApplicationRecord
  CURRENCIES = %w[USD TND EUR].freeze

  belongs_to :admin, class_name: "User"

  has_one_attached :logo

  has_many :coach_gyms, dependent: :destroy
  has_many :coaches, through: :coach_gyms, source: :user
  has_many :client_gyms, dependent: :destroy
  has_many :clients, through: :client_gyms, source: :user
  has_many :training_groups, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :name, presence: true
  validates :currency, inclusion: { in: CURRENCIES }
end
