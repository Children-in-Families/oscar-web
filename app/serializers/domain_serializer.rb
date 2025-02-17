class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :identity, :description, :score_1_color, :score_2_color, :score_3_color, :score_4_color,
             :score_5_color, :score_6_color, :score_7_color, :score_8_color, :score_9_color, :score_10_color,
             :score_1_definition, :score_2_definition, :score_3_definition, :score_4_definition,
             :score_5_definition, :score_6_definition, :score_7_definition, :score_8_definition, :score_9_definition, :score_10_definition,
             :domain_group_id, :tasks_count, :score_1, :score_2, :score_3, :score_4,
             :score_1_local, :score_2_local, :score_3_local, :score_4_local, :local_description,
             :score_1_local_definition, :score_2_local_definition, :score_3_local_definition, :score_4_local_definition,
             :score_5_local_definition, :score_6_local_definition, :score_7_local_definition, :score_8_local_definition,
             :score_9_local_definition, :score_10_local_definition, :custom_domain, :custom_assessment_setting_id,
             :created_at, :updated_at, :domain_type

  (1..10).each do |t|
    define_method("score_#{t}") { { color: object.send("score_#{t}_color"), definition: object.send("score_#{t}_definition") } }

    define_method("score_#{t}_local") { { color: object.send("score_#{t}_color"), definition: object.send("score_#{t}_local_definition") } }
  end
end
