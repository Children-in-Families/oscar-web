class DataTrackersController < AdminController
  load_and_authorize_resource

  before_action :find_form_type, :find_item_type

  def index
    page = params[:per_page] || 20

    if @item_type.present?
      if @form_type.present?
        @versions = filter_custom_field_versions
      else
        @versions = PaperTrail::Version.where(item_type: params[:item_type])
      end
    else
      @versions = PaperTrail::Version.where.not(item_type: exclude_item_type)
    end
    @versions = @versions.order(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def exclude_item_type
    %w(AdvancedSearch AssessmentDomain CaseNoteDomainGroup CaseNote AgencyClient Sponsor ClientQuantitativeCase ClientCustomField FamilyCustomField PartnerCustomField UserCustomField Location EnterNgo ExitNgo Referral)
  end

  def find_form_type
    @form_type = params[:formable_type]
  end

  def find_item_type
    @item_type = params[:item_type]
  end

  def filter_custom_field_versions
    PaperTrail::Version
      .where(item_type: @item_type)
      .where('(object ->> custom_formable_type) = ? OR (object_changes ->> custom_formable_type) = ?', @form_type, @form_type)
  end
end
