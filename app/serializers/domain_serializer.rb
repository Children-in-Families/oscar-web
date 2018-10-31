class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :identity, :description, :domain_group_id, :tasks_count, :score_1, :score_2, :score_3, :score_4, :created_at, :updated_at

  (1..4).each do |t|
    define_method("score_#{t}") { { color: object.send("score_#{t}_color"), definition: object.send("score_#{t}_definition") } }
  end
end
