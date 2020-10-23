export function confirmCancel(toastr, urlLocation=undefined) {

  const confirmText = $('#wrapper').data('confirm');
  const textYes = $('#wrapper').data('yes');
  const textNo = $('#wrapper').data('no');
  window.urlLocation = urlLocation

  toastr.warning("<br /><button class='btn btn-success m-r-xs' type='button' value='yes'>" + textYes + "</button><button class='btn btn-default btn-toastr-confirm' type='button'  value='no' >" + textNo + "</button>", confirmText, {
    preventDuplicates: true,
    closeButton: true,
    allowHtml: true,
    timeOut: 0,
    extendedTimeOut: 0,
    showDuration: '400',
    tapToDismiss: false,
    positionClass: 'toast-top-center',
    onclick: function() {
      let value = '';
      value = event.target.value;
      $('.toast-close-button').closest('.toast').remove();
      if (value === 'yes') {
        // if(urlLocation)
        //   document.location.href = urlLocation
        // else
        window.history.back()
      } else {
        return false;
      }
    }
  });
}

