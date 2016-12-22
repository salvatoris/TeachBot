# --- update username in navbar ---
update_header = (e, response) ->
	$ '#header_user_link'
		.text response.data.username

# --- send form with file (avatar) ---
upload_with_avatar = (event, elements) ->
	Form = new FormData document.getElementById 'edit_user_form'
	$.ajax
		url: event.currentTarget.action
		type: 'PATCH'
		data: Form
		contentType: false
		processData: false
		success: (response) ->
			$ '#edit_user_form'
				.trigger 'ajax:success', response

		error: (response) ->
			$ '#edit_user_form'
				.trigger 'ajax:error', response

	false

# --- add google autocomplete location ---
$(document).bind 'googleMaps', ->
	if $("#user_profile_attributes_location").length
		new google.maps.places.Autocomplete document.getElementById 'user_profile_attributes_location'

# --- exec after page loading ---
$ ->
	$(this).whenExist "body[id^='body_users_']", ->
		$ "#user_avatar"
			.change ->
				if this.files && this.files[0]
					reader = new FileReader();
					reader.onload = (e) ->
						$("#uploaded_avatar").hide().fadeIn(300).attr 'src', e.target.result
					reader.readAsDataURL(this.files[0]);

		$('#edit_user_form')
			.on 'ajax:success', (e, response) ->
			   update_header(e, response)
			   $(document).trigger('RMB:success', response.message)

			.on 'ajax:aborted:file', (event, elements) ->
			   upload_with_avatar(event, elements)
			   false

		$ '#new_user'
			.bind 'ajax:error', ->
			  grecaptcha.reset()

	$(this).whenExist '#body_users_new', ->
		$('#new_user').on 'ajax:error', (event, data) ->
			$(document).trigger 'RMB:ajax', { status: 422, data: data.responseJSON.error }