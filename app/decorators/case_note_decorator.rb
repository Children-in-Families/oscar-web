class CaseNoteDecorator < Draper::Decorator

	delegate_all

	def domain_note(domain)
		field = "domain_#{domain}_notes"
		if model.send(:"#{field}").present?
			h.content_tag(:div, "Domain #{domain} :", class: 'col-xs-2')
		end
	end

	def note_by_domain(domain)
		field = "domain_#{domain}_notes"
		if model.send(:"#{field}").present?
			h.content_tag(:div, class: 'col-xs-10') do
      	model.send(:"#{field}")
			end
		end
	end

end