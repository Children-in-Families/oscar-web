ActsAsParanoid::Core.module_eval do
  def update_counters_on_associations(method_sym)
    each_counter_cached_association_reflection do |assoc_reflection|
      reflection_options = assoc_reflection.options
      next unless reflection_options[:counter_cache]

      associated_object = send(assoc_reflection.name)
      next unless associated_object
      counter_cache_column = assoc_reflection.counter_cache_column
      associated_object.class.send(method_sym, counter_cache_column,
                                   associated_object.id)
      associated_object.touch if reflection_options[:touch]
    end
  end
end

