class QuantitativeTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :quantitative_cases_count, :multiple, :visible_on, :is_required, :hint, :field_type, :quantitative_cases

  def quantitative_cases
    object.quantitative_cases.as_json(only: %i[id value])
  end
end
