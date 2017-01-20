module Select2
  def select2_select(options={})
    within options[:from] do
      find('div.select2-container').click
      find('span.select2-chosen').set(options[:with])
    end

    # has_css?('ul.select2-results div', text: options[:with])
    # within '#select2-drop .select2-results' do
    #   find("div", text: options[:with]).click
    # end
    #
    # all('ul.select2-results__options li', text: options[:with]).each do |e|
    #  e.click if e.text.include?(options[:with])
    # end
  end

  def select2_search(options={})
    within options[:from] do
      find('span.select2.select2-container').click
    end
    find('input.select2-search__field').set(options[:with])
  end
end
