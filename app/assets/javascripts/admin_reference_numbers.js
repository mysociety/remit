(function($) {
  $(function () {
    // Only act on the new study admin page, just in case
    if ($('body.admin_studies.new').length > 0) {
      var $generatedReferenceId = $('#study_generated_reference_id');
      if ($generatedReferenceId.val() === '') {
        var prefix = window.ReMIT.currentReferenceNumberYear + '-';
        var nextNumber = window.ReMIT.currentReferenceNumber + 1;
        if(nextNumber < 10) {
          nextNumber = '0' + nextNumber.toString();
        }
        $generatedReferenceId.val(prefix + nextNumber);
      }
    }
  });
})(window.jQuery);
