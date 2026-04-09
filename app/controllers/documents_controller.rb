class DocumentsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_document, only: [:show, :edit, :update, :destroy, :download, :pdf]

  def index
    @documents = visible_documents.order(created_at: :desc)
  end

  def show
  end

  def new
    @document = Document.new
    load_collections
  end

  def create
    @document = Document.new(document_params)
    @document.created_by = current_user

    if @document.save
      redirect_to documents_path, notice: "Document created successfully."
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_collections
  end

  def update
    if @document.update(document_params)
      redirect_to documents_path, notice: "Document updated successfully."
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: "Document deleted successfully."
  end

  def download
    if @document.file.attached?
      redirect_to rails_blob_path(@document.file, disposition: "attachment")
    else
      redirect_to documents_path, alert: "No file attached for this document."
    end
  end

  def pdf
    require "prawn"

    pdf = Prawn::Document.new(page_size: "A4")
    pdf.text "Plannify Gym - Document Sheet", size: 18, style: :bold
    pdf.move_down 12
    pdf.text "Title: #{@document.title}", size: 12
    pdf.text "Type: #{t("documents.kinds.#{@document.kind}")}", size: 12
    pdf.text "Gym: #{@document.gym.name}", size: 12
    pdf.text "Created by: #{@document.created_by&.full_name || '-'}", size: 12
    pdf.text "Created at: #{I18n.l(@document.created_at, format: :long)}", size: 12
    pdf.move_down 12
    pdf.text "Description", size: 12, style: :bold
    pdf.text(@document.description.presence || "-")
    pdf.move_down 12
    pdf.text "Attached file: #{@document.file.attached? ? @document.file_name : 'No file attached'}", size: 11

    send_data pdf.render,
      filename: "document-#{@document.id}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end

  private

  def set_document
    @document = visible_documents.find(params[:id])
  end

  def visible_documents
    Document.includes(:gym, :created_by).where(gym: manageable_gyms)
  end

  def load_collections
    @gyms = manageable_gyms.order(:name)
    @kinds = Document::KINDS.map { |kind| [t("documents.kinds.#{kind}"), kind] }
  end

  def document_params
    params.require(:document).permit(:title, :kind, :description, :gym_id, :file)
  end
end
