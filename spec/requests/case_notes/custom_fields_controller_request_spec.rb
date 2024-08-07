require 'rails_helper'

RSpec.describe "CaseNotes::CustomFieldsControllers", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/case_notes/custom_fields_controller/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/case_notes/custom_fields_controller/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/case_notes/custom_fields_controller/show"
      expect(response).to have_http_status(:success)
    end
  end

end
