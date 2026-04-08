class PaymentReceipt < ApplicationRecord
  belongs_to :payment
  belongs_to :generated_by, class_name: "User"

  validates :payment_id, uniqueness: true
  validates :generated_at, :gym_signature_data, presence: true

  def self.build_snapshot(payment, generated_by)
    client = payment.client
    gym = client.gym
    gym_ids = gym.present? ? [gym.id] : []
    currency_code = gym&.currency || "TND"
    coach_rows = User.coaches
      .where(gym_id: gym_ids)

    {
      payment: {
        id: payment.id,
        amount: payment.amount.to_f,
        currency: currency_code,
        starts_on: payment.starts_on,
        ends_on: payment.ends_on,
        duration_months: payment.duration_months,
        duration_label: payment.duration_label,
        status: payment.status,
        notes: payment.notes
      },
      client: {
        id: client.id,
        full_name: client.full_name,
        email: client.email,
        phone_number: client.phone_number,
        groups: client.groups.select(:id, :name).map { |group| { id: group.id, name: group.name } }
      },
      gyms: (gym.present? ? [{ id: gym.id, name: gym.name, address: gym.address, currency: gym.currency }] : []),
      coaches: coach_rows.map do |coach|
        {
          id: coach.id,
          full_name: coach.full_name,
          email: coach.email,
          phone_number: coach.phone_number,
          gyms: gym.present? ? [gym.name] : []
        }
      end,
      generated_by: {
        id: generated_by.id,
        full_name: generated_by.full_name,
        email: generated_by.email
      },
      generated_at: Time.current.iso8601
    }
  end
end