module CapybaraFormSubmitHelper
  class Capybara::Node::Element
    # If self is a form element, submit the form by building a
    # parameters from all 'input' tags within this form.
    def submit(button)
      raise "Can only submit form, not #{tag_name}" unless tag_name =~ /form/i

      method = has_css?('input[name="_method"]', visible: false) ? find('[name=_method]', visible: false).value.to_sym : self['method'].to_sym
      url = self['action']
      params = all(:css, 'input').reduce({}) do |acc, input|
        acc.store(input['name'], input['value'])
        acc
      end

      select = {
                "referral[consent_form]"=> fixture_file_upload('spec/supports/file.docx', 'image/jpeg')
              }
      params['commit'] = button
      params = params.merge(select)
      session = ActionDispatch::Integration::Session.new(Rails.application)

      session.post(url, params)
    end
  end
end
