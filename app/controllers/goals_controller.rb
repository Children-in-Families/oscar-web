class GoalsController < AdminController
  #commented because not in use yet
  
  # load_and_authorize_resource
  # before_action :find_care_plan
  # before_action :authorize_client, only: [:new, :create]
  # before_action :find_goal, only: [:edit, :update, :destroy]

  # def index
  #   @goals = @care_plan.goals
  # end

  # def create
  #   @goal = @care_plan.goals.new(goal_params)
  #   respond_to do |format|
  #     if @goal.save
  #       format.json { render json: @goal.to_json, status: 200 }
  #       format.html { redirect_to client_care_plans_path(@care_plan), notice: t('.successfully_created') }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @goal.errors, status: 422 }
  #     end
  #   end
  # end

  # def edit
  # end

  # def update
  #   if @goal.update_attributes(goal_params)
  #     redirect_to client_care_plans_path(@care_plan), notice: t('.successfully_updated')
  #   else
  #     render :edit
  #   end
  # end

  # def destroy
  #   respond_to do |format|
  #     if @goal.destroy
  #       msg = { status: 'ok', message: t('.successfully_deleted') }
  #       format.json { render json: msg }
  #       format.html { redirect_to client_care_plans_path(@client), notice: t('.successfully_deleted') }
  #     else
  #       format.json { render json: @goal.errors, status: 422 }
  #       format.html { redirect_to client_care_plans_path(@client), alert: t('.failed_delete') }
  #     end
  #   end
  # end

  # private

  # def find_client
  #   @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  # end

  # def goal_params
  #   params.require(:goal).permit(:domain_id, :description, :assessment_domain_id, :assessment_id)
  # end

  # def encode32hex(str)
  #   str.gsub(/\G(.{5})|(.{1,4}\z)/mn) do
  #     full = $1; frag = $2
  #     n, c = (full || frag.ljust(5, "\0")).unpack("NC")
  #     full = ((n << 8) | c).to_s(32).rjust(8, "0")
  #     if frag
  #       full[0, (frag.length*8+4).div(5)].ljust(8, "=")
  #     else
  #       full
  #     end
  #   end
  # end

  # HEX = '[0-9a-v]'
  # def decode32hex(str)
  #   str.gsub(/\G\s*(#{HEX}{8}|#{HEX}{7}=|#{HEX}{5}={3}|#{HEX}{4}={4}|#{HEX}{2}={6}|(\S))/imno) do
  #     raise "invalid base32" if $2
  #     s = $1
  #     s.tr("=", "0").to_i(32).divmod(256).pack("NC")[0,(s.count("^=")*5).div(8)]
  #   end
  # end

  # def find_goal
  #   @goal = @care_plan.goals.find(params[:id])
  # end

  # def authorize_client
  #   authorize @client, :create?
  # end

end
