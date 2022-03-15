Hash.class_eval do
  def to_struct
    Struct.new(*keys.map(&:to_sym)).new(*values)
  end
end