class AddReportFieldsToUsageReports < ActiveRecord::Migration
  def change
    add_column :usage_reports, :added_cases, :jsonb, default: {}
    add_column :usage_reports, :synced_cases, :jsonb, default: {}
    add_column :usage_reports, :cross_referral_cases, :jsonb, default: {}
    add_column :usage_reports, :cross_referral_to_primero_cases, :jsonb, default: {}
    add_column :usage_reports, :cross_referral_from_primero_cases, :jsonb, default: {}
  end
end
