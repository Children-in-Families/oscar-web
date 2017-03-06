class FilterConditions
  attr_accessor :display_fields

  def initialize(resource)
    @resource = resource
  end

  def resource
    @resource.select(:id, :first_name, display_fields)  
  end

  def is(column, value)
    @resource = @resource.where("#{column} = ?", "#{value}")
  end

  def is_not(column, value)
    @resource = @resource.where("#{column} != ?", "#{value}")
  end

  def less(column, value)
    @resource = @resource.where("#{column} < ?", "#{value}")
  end

  def less_or_equal(column, value)
    @resource = @resource.where("#{column} <= ?", "#{value}")
  end

  def greater(column, value)
    @resource = @resource.where("#{column} > ?", "#{value}")
  end

  def greater_or_equal(column, value)
    @resource = @resource.where("#{column} >= ?", "#{value}")
  end

  def contains(column, value)
    @resource = @resource.where("#{column} ILIKE ?", "%#{value}%")
  end

  def not_contains(column, value)
    @resource = @resource.where("#{column} NOT ILIKE ?", "%#{value}%")
  end

  def rang_between(column, value)
    @resource = @resource.where(column.to_sym => (value[0]...value[1]))
  end
end