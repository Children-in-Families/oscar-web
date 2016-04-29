$(document).on 'ready page:load', ->
	$('#filtered_by_user select').change ->
		$('#filtered_by_user').submit()