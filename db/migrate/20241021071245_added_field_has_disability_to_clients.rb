class AddedFieldHasDisabilityToClients < ActiveRecord::Migration
  def change
    add_column :clients, :has_disability, :boolean, default: false
    add_column :clients, :disability_specification, :string

    reversible do |dir|
      dir.up do
        Client.includes(:risk_assessment, quantitative_cases: :quantitative_type).each do |client|
          risk_assessment = client.risk_assessment
          if risk_assessment
            client.update_columns(has_disability: risk_assessment.has_disability, disability_specification: risk_assessment.disability_specification)
          end

          quantitative_cases = client.quantitative_cases
          if !client.has_disability && quantitative_cases
            quantitative_type = quantitative_cases.joins(:quantitative_type).where(quantitative_types: { name: 'ពិការភាព/Disability' }).first.try(:quantitative_type)
            if quantitative_type
              client.update_columns(has_disability: true)
            end
          end
        end
      end
    end
  end
end
