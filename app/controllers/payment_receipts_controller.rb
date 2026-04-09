class PaymentReceiptsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_payment

  def show
    @receipt = @payment.receipt
    return if @receipt

    redirect_to new_payment_receipt_path(@payment), alert: "No receipt generated yet for this payment."
  end

  def pdf
    @receipt = @payment.receipt
    unless @receipt
      redirect_to new_payment_receipt_path(@payment), alert: "No receipt generated yet for this payment."
      return
    end

    snapshot = @receipt.details_snapshot || {}
    payment_snapshot = snapshot["payment"] || snapshot[:payment] || {}
    client_snapshot = snapshot["client"] || snapshot[:client] || {}
    gyms_snapshot = snapshot["gyms"] || snapshot[:gyms] || []
    coaches_snapshot = snapshot["coaches"] || snapshot[:coaches] || []
    generated_by_snapshot = snapshot["generated_by"] || snapshot[:generated_by] || {}
    currency_code = payment_snapshot["currency"] || payment_snapshot[:currency] || gyms_snapshot.first&.dig("currency") || gyms_snapshot.first&.dig(:currency) || "TND"

    if coaches_snapshot.blank?
      client_gym = @payment.client.gym
      coaches_snapshot = User.coaches
        .where(gym_id: client_gym&.id)
        .map do |coach|
          {
            "full_name" => coach.full_name,
            "email" => coach.email,
            "phone_number" => coach.phone_number,
            "gyms" => client_gym.present? ? [client_gym.name] : []
          }
        end
    end

    if payment_snapshot["currency"].blank? && payment_snapshot[:currency].blank?
      payment_snapshot = payment_snapshot.merge("currency" => @payment.client.gym&.currency || "TND")
    end

    require "prawn"
    require "stringio"
    require "base64"

    pdf = Prawn::Document.new(page_size: "A4", margin: 28)

    draw_pdf_banner(pdf, @receipt)
    pdf.move_down 12

    copy_rows = [
      ["Date generation", @receipt.generated_at.strftime("%Y-%m-%d %H:%M")],
      ["Montant", format_amount(payment_snapshot["amount"] || payment_snapshot[:amount], currency_code)],
      ["Periode", "#{payment_snapshot["starts_on"] || payment_snapshot[:starts_on]} -> #{payment_snapshot["ends_on"] || payment_snapshot[:ends_on]}"],
      ["Statut", (payment_snapshot["status"] || payment_snapshot[:status]).to_s.upcase],
      ["Client", client_snapshot["full_name"] || client_snapshot[:full_name]],
      ["Email client", client_snapshot["email"] || client_snapshot[:email]],
      ["Telephone client", client_snapshot["phone_number"] || client_snapshot[:phone_number]],
      ["Genere par", generated_by_snapshot["full_name"] || generated_by_snapshot[:full_name]]
    ]

    gyms_label = gyms_snapshot.map { |gym| "#{gym["name"] || gym[:name]} (#{gym["address"] || gym[:address] || "-"})" }.join(" | ")
    copy_rows << ["Salle(s)", gyms_label.presence || "-"]

    draw_section_heading(pdf, "COPIE SALLE")
    draw_info_rows(pdf, copy_rows)

    coaches_text = if coaches_snapshot.any?
      coaches_snapshot.map do |coach|
        gyms_for_coach = coach["gyms"] || coach[:gyms] || []
        "- #{coach["full_name"] || coach[:full_name]} | #{coach["email"] || coach[:email]} | #{coach["phone_number"] || coach[:phone_number] || "-"} | Gyms: #{gyms_for_coach.join(", ")}"
      end.join("\n")
    else
      "-"
    end

    pdf.move_down 8
    pdf.fill_color "1F2937"
    pdf.text "Coach(s)", size: 10, style: :bold
    pdf.move_down 3
    pdf.fill_color "334155"
    pdf.text coaches_text, size: 9, leading: 2
    pdf.fill_color "000000"

    add_signatures(pdf, @receipt)

    draw_cut_line(pdf)

    draw_section_heading(pdf, "TICKET CLIENT")
    ticket_rows = [
      ["No recu", @receipt.id],
      ["Client", client_snapshot["full_name"] || client_snapshot[:full_name]],
      ["Montant", format_amount(payment_snapshot["amount"] || payment_snapshot[:amount], currency_code)],
      ["Periode", "#{payment_snapshot["starts_on"] || payment_snapshot[:starts_on]} -> #{payment_snapshot["ends_on"] || payment_snapshot[:ends_on]}"],
      ["Salle", gyms_snapshot.map { |gym| gym["name"] || gym[:name] }.join(", ")],
      ["Date", @receipt.generated_at.to_date.to_s]
    ]
    draw_info_rows(pdf, ticket_rows)

    pdf.move_down 10
    pdf.stroke_color "94A3B8"
    pdf.stroke_horizontal_rule
    pdf.move_down 8
    pdf.fill_color "1F2937"
    pdf.text "Signature client: _________________________________", size: 9
    pdf.text "(Le client signe cette partie sur papier)", size: 8
    pdf.fill_color "000000"

    send_data pdf.render,
      filename: "payment-receipt-#{@receipt.id}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end

  def new
    if @payment.receipt.present?
      redirect_to payment_receipt_path(@payment), notice: "Receipt already generated for this payment."
      return
    end

    unless @payment.paid?
      redirect_to payments_path, alert: "Receipt can only be generated for payments with status paid."
      return
    end

    @receipt = @payment.build_receipt
  end

  def create
    if @payment.receipt.present?
      redirect_to payment_receipt_path(@payment), notice: "Receipt already generated for this payment."
      return
    end

    unless @payment.paid?
      redirect_to payments_path, alert: "Receipt can only be generated for payments with status paid."
      return
    end

    @receipt = @payment.build_receipt(receipt_params)
    @receipt.generated_by = current_user
    @receipt.generated_at = Time.current
    @receipt.details_snapshot = PaymentReceipt.build_snapshot(@payment, current_user)

    if @receipt.save
      redirect_to payment_receipt_path(@payment), notice: "Receipt generated and saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_payment
    @payment = visible_payments.find(params[:payment_id])
  end

  def visible_payments
    Payment.where(id: visible_payment_base_scope.select(:id).distinct)
      .includes(:receipt, :created_by, client: [:groups, :gym])
  end

  def visible_payment_base_scope
    Payment
      .joins(:client)
      .where(users: { gym_id: manageable_gyms.select(:id) })
  end

  def receipt_params
    params.require(:payment_receipt).permit(:gym_signature_data)
  end

  def draw_key_value(pdf, label, value)
    pdf.text "#{label}: #{value.presence || '-'}", size: 10
  end

  def draw_pdf_banner(pdf, receipt)
    top = pdf.cursor
    height = 64

    pdf.fill_color "0F172A"
    pdf.fill_rounded_rectangle [pdf.bounds.left, top], pdf.bounds.width, height, 8

    pdf.fill_color "FFFFFF"
    pdf.bounding_box([pdf.bounds.left + 14, top - 10], width: pdf.bounds.width - 28, height: height - 14) do
      pdf.text "RECU DE PAIEMENT", size: 17, style: :bold
      pdf.move_down 2
      pdf.text "No: #{receipt.id}", size: 9
      pdf.text "Genere le #{receipt.generated_at.strftime("%Y-%m-%d %H:%M")}", size: 9
    end

    pdf.fill_color "000000"
    pdf.move_down(height + 2)
  end

  def draw_section_heading(pdf, title)
    pdf.move_down 4
    pdf.fill_color "0F766E"
    pdf.text title, size: 11, style: :bold
    pdf.fill_color "94A3B8"
    pdf.stroke_horizontal_rule
    pdf.fill_color "000000"
    pdf.move_down 6
  end

  def draw_info_rows(pdf, rows)
    rows.each do |label, value|
      pdf.fill_color "475569"
      pdf.formatted_text([
        { text: "#{label}: ", styles: [:bold], size: 9 },
        { text: (value.presence || "-").to_s, size: 9 }
      ])
      pdf.move_down 3
    end
    pdf.fill_color "000000"
  end

  def draw_cut_line(pdf)
    pdf.move_down 14
    pdf.stroke_color "64748B"
    pdf.dash(5, space: 4)
    pdf.stroke_horizontal_rule
    pdf.undash
    pdf.move_down 4
    pdf.fill_color "475569"
    pdf.text "COUPER ICI ET REMETTRE LA PARTIE CLIENT", size: 8, align: :center, style: :bold
    pdf.fill_color "000000"
    pdf.move_down 8
  end

  def format_amount(amount, currency_code)
    return nil if amount.blank?

    "#{amount} #{currency_code}"
  end

  def signature_io(data_url)
    return nil if data_url.blank? || !data_url.include?(",")

    encoded = data_url.split(",", 2).last
    StringIO.new(Base64.decode64(encoded))
  rescue StandardError
    nil
  end

  def add_signatures(pdf, receipt)
    gym_sign = signature_io(receipt.gym_signature_data)

    pdf.move_down 10
    pdf.stroke_color "94A3B8"
    pdf.stroke_horizontal_rule
    pdf.move_down 6
    pdf.fill_color "1F2937"
    pdf.text "Signatures", size: 10, style: :bold
    pdf.move_down 4

    if gym_sign
      pdf.text "Signature salle:", size: 9
      pdf.image gym_sign, fit: [180, 60]
    end

    pdf.move_down 8
    pdf.text "Signature client: _________________________________", size: 9
    pdf.text "(Signature manuelle sur papier)", size: 8
    pdf.fill_color "000000"
  end
end