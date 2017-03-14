class BaseFilters
  attr_accessor :resource

  def initialize(resource)
    @resource = resource
  end

  def is(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} = ?", value)
  end

  def is_not(table_name, column, value)
    @resource = @resource.where.not("#{table_name}.#{column} = ?", value)
  end

  def less(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} < ?", value)
  end

  def less_or_equal(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} <= ?", value)
  end

  def greater(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} > ?", value)
  end

  def greater_or_equal(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} >= ?", value)
  end

  def contains(table_name, column, value)
    @resource = @resource.where("#{table_name}.#{column} ILIKE ?", "%#{value}%")
  end

  def not_contains(table_name, column, value)
    @resource = @resource.where.not("#{table_name}.#{column} ILIKE ?", "%#{value}%")
  end

  def range_between(table_name, column, value)
    @resource = @resource.where(column.to_sym => (value[0]..value[1]))
  end

end
