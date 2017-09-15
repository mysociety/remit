(function($) {
  $(function () {
    // Only act on the new study admin page, just in case
    if ($('body.admin_studies.new').length > 0) {
      var $generatedReferenceId = $('#study_generated_reference_id');

      if ($generatedReferenceId.val() === '') {
        $generatedReferenceId.val(generate_reference(window.ReMIT.currentReferenceNumber));
      }

      $("#study_operating_center").on('change', function() {
        $generatedReferenceId.val(generate_reference($(this).children('option:selected').data("current-reference-number")));
      });
    }

    function generate_reference(currentReferenceNumber) {
      var prefix = window.ReMIT.currentReferenceNumberYear + '-';
      var nextNumber = currentReferenceNumber + 1;
      if(nextNumber < 10) {
        nextNumber = '0' + nextNumber.toString();
      }

      return prefix + nextNumber
    }
  });
})(window.jQuery);
