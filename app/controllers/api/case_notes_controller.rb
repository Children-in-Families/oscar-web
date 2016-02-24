module Api
  class CaseNotesController < BaseApiController
    before_action :set_kinship_or_foster_care_case, only: [:create]
    before_action :connect_db

    def create
      case_note = @kinship_or_foster_care_case.case_notes.new(case_note_params)

      case_note.transaction do
        case_note.save

        begin
          doc = @remote_temp_db.get(params[:doc_id])
          @remote_temp_db.delete_doc(doc)

          render json: { notice: 'Case note was successfully created.', id: case_note.id }
        rescue RestClient::Exception => e
          raise ActiveRecord::Rollback
        end
      end
    end

    private

    def set_kinship_or_foster_care_case
      @kinship_or_foster_care_case = KinshipOrFosterCareCase.find(params[:kinship_or_foster_care_case_id])
    end

    def case_note_params
      params.require(:case_note).permit(:date, :present, :case_worker_id, case_note_domain_groups_attributes: [:domain_group_id, :note])
    end
  end
end
