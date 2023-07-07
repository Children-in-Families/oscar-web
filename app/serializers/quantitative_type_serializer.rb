class QuantitativeTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :quantitative_cases

  def quantitative_cases
    object.quantitative_cases
  end
end
