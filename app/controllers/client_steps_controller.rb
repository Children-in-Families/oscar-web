class ClientStepsController < ApplicationController
  include Wicked::Wizard

  steps :living_detail, :other_detail, :specific_point

  def show
    @provinces = Province.all
    @districts = District.all
    @province  = Province.order(:name)
    @donors    = Donor.all
    @agencies  = Agency.order(:name)
    @client    = Client.accessible_by(current_ability).friendly.find(session[:client_id])
    render_wizard
  end

  def update
    @client = Client.accessible_by(current_ability).friendly.find(session[:client_id])
    @client.attributes.merge(params[:client])
    render_wizard @client
  end

  private

  def redirect_to_finish_wizard
    redirect_to root_url, notice: "Thank you for signing up."
  end

end
