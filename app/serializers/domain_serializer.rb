class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :identity, :description,  :score_1_color, :score_2_color, :score_3_color, :score_4_color, :score_1_definition, :score_2_definition, :score_3_definition, :score_4_definition, :domain_group_id, :tasks_count, :score_1, :score_2, :score_3, :score_4, :created_at, :updated_at

  (1..4).each do |t|
    define_method("score_#{t}") { { color: object.send("score_#{t}_color"), definition: object.send("score_#{t}_definition") } }
  end
end
