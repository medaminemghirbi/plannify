class Document < ApplicationRecord
  KINDS = ["contract", "policy", "medical", "invoice", "other"].freeze

  belongs_to :gym
  belongs_to :created_by, class_name: "User", optional: true

  has_one_attached :file

  validates :title, presence: true
  validates :kind, inclusion: { in: KINDS }

  def file_name
    file.filename.to_s
  end
end
