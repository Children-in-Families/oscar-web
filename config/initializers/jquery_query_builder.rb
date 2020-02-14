module JqueryQueryBuilder
  class Evaluator
    def get_matching_objects(objects)
      objects.select do |o|
        object_matches_rules?(o)
      end
    end
  end

  class RuleGroup
    def evaluate(object)
      case condition
      when "AND"
        rules.all?{|rule| rule['field'] = rule['id']; get_rule_object(rule).evaluate(object) }
      when "OR"
        rules.any?{|rule| rule['field'] = rule['id']; get_rule_object(rule).evaluate(object) }
      end
    end
  end
end
