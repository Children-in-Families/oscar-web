CIF.SettingsIndex = CIF.SettingsScreening_forms = CIF.SettingsCare_plan = CIF.SettingsEdit = CIF.SettingsUpdate = CIF.SettingsCreate = CIF.SettingsDefault_columns = do ->
	_init = ->
		_initSelect2()
		_handleDefaultAssessmentCheckbox()
		_ajaxChangeDistrict()
		_initICheckBox()
		_handleCustomAssessmentCheckbox()
		_handleInitCocoonForCustomAssessmentSetting()
		_toggleDeleteIncomplete()

	_initICheckBox = ->
		$('.ichecks-radio_buttons').iCheck
			checkboxClass: 'icheckbox_square-green'
			radioClass: 'iradio_square-green'

		$('.i-checks').iCheck(
			checkboxClass: 'icheckbox_square-green'
			radioClass: 'iradio_square-green'
		).on('ifChecked', ->
			currentSettingId = $(this).data('current-setting')

			if currentSettingId
				$.ajax
					type: 'PUT'
					url: "settings/#{currentSettingId}"
					data: { setting: { enable_custom_assessment: true } }
					dataType: 'JSON'
					success: (json) ->
						return

			if $(this).attr("id") == "setting_use_screening_assessment"
				$(".screening-assessment-form").removeClass("hidden")

			if $(this).attr("id") == "setting_disable_required_fields"
				$("#care-plan-setting").removeClass('hidden')
		).on('ifUnchecked', ->
			if $(this).attr("id") == "setting_use_screening_assessment"
				$(".screening-assessment-form").addClass("hidden")

			if $(this).attr("id") == "setting_disable_required_fields"
				$("#care-plan-setting").addClass('hidden')
		)

	_toggleDeleteIncomplete = ->
		$("#setting_never_delete_incomplete_assessment").on "ifUnchecked", ->
			$("#delete-incomplete-time").show()
		$("#setting_never_delete_incomplete_assessment").on "ifChecked", ->
			$("#delete-incomplete-time").hide()

	_initSelect2 = ->
		$('select').select2()
		$("[id*='_custom_assessment_frequency']").on 'select2-selected', (element) ->
			prefixId = @.id.match(/.*\d\_/)[0]
			maxCustomAssessment = $("##{prefixId}max_custom_assessment")
			if @.value == 'unlimited'
				maxCustomAssessment.val(0)
				maxCustomAssessment.parent().removeClass('has-error')
				maxCustomAssessment.siblings().hide()
				maxCustomAssessment.prop('disabled', true)
			else
				maxCustomAssessment.prop('disabled', false)


	_handleInitCocoonForCustomAssessmentSetting = ->
		$('#custom_assessment_settings').off('cocoon:after-insert').on 'cocoon:after-insert', ->
			_initICheckBox()
			_handleCustomAssessmentCheckbox()
			_initSelect2()

	_handleCustomAssessmentCheckbox = ->
		_disableCustomAssessmentSetting()
		$('#checkbox_custom_assessment_setting.i-checks').on 'ifUnchecked', ->
			checkbox_index_val = event.target.previousSibling.name.split('setting').slice(-1)[0].split('[')[1].split(']')[0]
			custom_assessment_name = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_assessment_name"
			max_custom_assessment = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_max_custom_assessment"
			custom_assessment_frequency = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_assessment_frequency"
			custom_age = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_age"

			$(custom_assessment_name).prop('disabled', true)
			$(max_custom_assessment).prop('disabled', true)
			$(custom_assessment_frequency).prop('disabled', true)
			$(custom_age).prop('disabled', true)

		$('#checkbox_custom_assessment_setting.i-checks').on 'ifChecked', ->
			checkbox_index_val = event.target.previousSibling.name.split('setting').slice(-1)[0].split('[')[1].split(']')[0]
			custom_assessment_name = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_assessment_name"
			max_custom_assessment = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_max_custom_assessment"
			custom_assessment_frequency = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_assessment_frequency"
			custom_age = "#setting_custom_assessment_settings_attributes_#{checkbox_index_val}_custom_age"

			$(custom_assessment_name).prop('disabled', false)
			$(max_custom_assessment).prop('disabled', false)
			$(custom_assessment_frequency).prop('disabled', false)
			$(custom_age).prop('disabled', false)

	_disableCustomAssessmentSetting = ->
		$('#checkbox_custom_assessment_setting.i-checks').each (index) ->
			if this.checked == false
				checkbox_val = this.name.split('setting').slice(-1)[0].split('[')[1].split(']')[0]
				custom_assessment_name = "#setting_custom_assessment_settings_attributes_#{checkbox_val}_custom_assessment_name"
				max_custom_assessment = "#setting_custom_assessment_settings_attributes_#{checkbox_val}_max_custom_assessment"
				custom_assessment_frequency = "#setting_custom_assessment_settings_attributes_#{checkbox_val}_custom_assessment_frequency"
				custom_age = "#setting_custom_assessment_settings_attributes_#{checkbox_val}_custom_age"

				$(custom_assessment_name).prop('disabled', true)
				$(max_custom_assessment).prop('disabled', true)
				$(custom_assessment_frequency).prop('disabled', true)
				$(custom_age).prop('disabled', true)

	_handleDefaultAssessmentCheckbox = ->
		_disableAssessmentSetting()
		$('#setting_enable_default_assessment.i-checks').on 'ifUnchecked', ->
			$('#default-assessment-setting .panel-body').find('input, select').prop('disabled', true)
		$('#setting_enable_default_assessment.i-checks').on 'ifChecked', ->
			$('#default-assessment-setting .panel-body').find('input, select').prop('disabled', false)

	_disableAssessmentSetting = ->
		disableDefaultAssessmentChecked = $('#setting_enable_default_assessment').is(':unchecked')
		$('#default-assessment-setting .panel-body').find('input, select').prop('disabled', true) if disableDefaultAssessmentChecked

	_ajaxChangeDistrict = ->
		mainAddress = $('#setting_province_id, #setting_district_id')
		mainAddress.on 'change', ->
			type = $(@).data('type')
			typeId = $(@).val()
			subAddress = $(@).data('subaddress')

			if type == 'provinces' && subAddress == 'district'
				subResources = 'districts'
				subAddress = $('#setting_district_id')

				$(subAddress).val(null).trigger('change')
				$(subAddress).find('option[value!=""]').remove()
			else if type == 'districts' && subAddress == 'commune'
				subResources = 'communes'
				subAddress = $('#setting_commune_id')

				$(subAddress).val(null).trigger('change')
				$(subAddress).find('option[value!=""]').remove()

			if typeId != ''
				$.ajax
					method: 'GET'
					url: "/api/#{type}/#{typeId}/#{subResources}"
					dataType: 'JSON'
					success: (response) ->
						for address in response.data
							subAddress.append("<option value='#{address.id}'>#{address.name}</option>")

	{ init: _init }
