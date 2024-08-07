# frozen_string_literal: true

module CaseNotes
  class CustomFieldsController < ApplicationController
    before_action :redirect_to_edit, only: [:new]
    before_action :clean_params, only: [:create, :update]

    def new
      @custom_field = CaseNotes::CustomField.new
    end

    def create
      @custom_field = CaseNotes::CustomField.new(custom_field_params)
      if @custom_field.save
        redirect_to edit_case_notes_custom_field_path, notice: 'Custom field was successfully created.'
      else
        render :new
      end
    end

    def edit
      @custom_field = CaseNotes::CustomField.first
    end

    def update
      @custom_field = CaseNotes::CustomField.first
      if @custom_field.update(custom_field_params)
        redirect_to edit_case_notes_custom_field_path, notice: 'Custom field was successfully updated.'
      else
        render :edit
      end
    end

    private

    def redirect_to_edit
      redirect_to(edit_case_notes_custom_field_path) if CaseNotes::CustomField.any?
    end

    def clean_params
      fields = params[:custom_field][:fields]
      params[:custom_field][:fields] = ActionController::Base.helpers.strip_tags(fields).gsub(/(\\n)|(\\t)/, '')
    end

    def custom_field_params
      params.require(:custom_field).permit(:fields)
    end
  end
end
