module Select2
  def select2_select(value, element_selector)
    select2_container = first("#{element_selector}")
    select2_container.find(".select2-choice").click

    drop_container = ".select2-results"
    find(:xpath, "//body").find("#{drop_container} li", text: value).click
  end
end
