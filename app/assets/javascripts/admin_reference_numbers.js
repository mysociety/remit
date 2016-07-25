(function($) {
  $(function () {
    // Only act on the new study admin page, just in case
    if ($('body.admin_studies.new').length > 0) {
      var $referenceNumberField = $('#study_reference_number');
      if ($referenceNumberField.val() === '') {
        var prefix = 'OCA' + window.ReMIT.currentReferenceNumberYear + '-';
        var nextNumber = window.ReMIT.currentReferenceNumber + 1;
        $referenceNumberField.val(prefix + nextNumber);
      }
    }
  });
})(window.jQuery);