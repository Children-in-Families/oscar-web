class Array
  def binary_search(targeted_value, low = 0, high = nil)
    high ||= size - 1
    mid = (low + high) / 2

    return "Not found" if low > high

    if targeted_value == self[mid]
      return mid
    elsif targeted_value > self[mid]
      binary_search(targeted_value, mid + 1, high)
    else
      binary_search(targeted_value, low, mid - 1)
    end
  end
end
