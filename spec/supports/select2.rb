module Select2
  def select2_select(options={})
    within options[:from] do
      find('span.select2.select2-container').click
    end
    find('input.select2-search__field').set(options[:with])
    has_css?('ul.select2-results__options li', text: options[:with])
    all('ul.select2-results__options li', text: options[:with]).each do |e|
      e.click if e.text.include?(options[:with])
    end
  end

  def select2_search(options={})
    within options[:from] do
      find('span.select2.select2-container').click
    end
    find('input.select2-search__field').set(options[:with])
  end
end
