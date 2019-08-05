class CreateAllDonorOrganization < ActiveRecord::Migration
  def change
    create_table :all_donor_organizations do |t|
      t.references :all_donor, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
    end

    reversible do |dir|
      dir.up { create_all_donors if schema_search_path == "\"public\"" }
    end
  end

  def create_all_donors
    donors = Organization.pluck(:id, :short_name).map do |org_id, short_name|
      Organization.switch_to short_name
      Donor.all.map do |donor|
        [[org_id, short_name], [donor.id, donor.name]]
      end
    end

    donor_names = donors.reject(&:blank?).map do |group|
      group.flatten(1)[1..-1].map(&:last)
    end

    donor_values = donor_names.flatten.uniq.map{ |donor_name| { name: donor_name.strip } }

    Organization.switch_to 'public'

    org_donors = donors.reject(&:blank?).map do |group|
      org_donor = group.flatten(1).to_h.to_a
      org, donors = org_donor[0], org_donor[1..-1]

      donors.to_h.values.uniq.map{ |donor_name| { name: donor_name.strip } }.each do |donor|
        AllDonor.find_or_create_by(donor)
      end

      donors.to_h.values.uniq.map{ |donor_name| { organization_id: org[0], all_donor_id: AllDonor.find_by(name: donor_name.strip).id } }.each do |donor_org|
        AllDonorOrganization.find_or_create_by(donor_org)
      end
    end
  end
end
