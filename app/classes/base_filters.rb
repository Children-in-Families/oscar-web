class BaseFilters
  attr_accessor :resource

  def initialize(resource)
    @resource = resource
  end

  def is(column, value)
    @resource = @resource.where({column.to_sym => value})
  end

  def is_not(column, value)
    @resource = @resource.where.not({column.to_sym => value})
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
    @resource = @resource.where.not("#{column} ILIKE ?", "%#{value}%")
  end

  def range_between(column, value)
    @resource = @resource.where(column.to_sym => (value[0]..value[1]))
  end

end