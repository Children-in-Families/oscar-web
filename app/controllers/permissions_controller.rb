class PermissionsController < AdminController

  def create
    Permission.create(permission_params)
    redirect_to user_path(params[:user_id]), notice: "User's permission has been created successfully."
  end

  def update   
    permission = Permission.find(params[:id])
    permission.update(permission_params)
    redirect_to user_path(params[:user_id]), notice: "User's permission has been updated successfully."
  end

  private

  def permission_params
    params.require(:permission).permit(:case_notes_editable, :case_notes_readable, :assessments_readable, :assessments_editable).merge(user_id: params[:user_id])
  end
end