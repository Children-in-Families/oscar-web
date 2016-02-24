module Api
  class CaseNoteTasksController < BaseApiController
    before_action :set_kinship_or_foster_care_case, only: [:create, :update]
    before_action :connect_db

    def create
      task = @kinship_or_foster_care_case.case_tasks.new(task_params)

      task.transaction do
        task.save

        begin
          doc = @remote_temp_db.get(params[:doc_id])
          @remote_temp_db.delete_doc(doc)

          render json: { notice: 'Task was successfully created.', id: task.id }
        rescue RestClient::Exception => e
          raise ActiveRecord::Rollback
        end
      end
    end

    def update
      task = @kinship_or_foster_care_case.case_note_tasks.find(params[:id])

      task.transaction do
        task.update(task_params)

        begin
          doc = @remote_temp_db.get(params[:doc_id])
          @remote_temp_db.delete_doc(doc)

          render json: { notice: 'Task was successfully created.', id: task.id }
        rescue RestClient::Exception => e
          raise ActiveRecord::Rollback
        end
      end
    end

    private

    def set_kinship_or_foster_care_case
      @kinship_or_foster_care_case = KinshipOrFosterCareCase.find(params[:kinship_or_foster_care_case_id])
    end

    def task_params
      params.require(:case_note_task).permit(:domain_group_id, :name)
    end
  end
end
