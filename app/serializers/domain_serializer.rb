class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :identity, :description, :domain_group_id, :tasks_count, :score_1, :score_2, :score_3, :score_4, :created_at, :updated_at

  def score_1
    { color: object.score_1_color, definition: object.score_1_definition }
  end

  def score_2
    { color: object.score_2_color, definition: object.score_2_definition }
  end

  def score_3
    { color: object.score_3_color, definition: object.score_3_definition }
  end

  def score_4
    { color: object.score_4_color, definition: object.score_4_definition }
  end
end
