$(function(){
  $('select').each(function(){
    var settings = {};

    // Add a search box, if there are 10 or more options
    var numberOfOptions = $(this).find('option').length;
    if(numberOfOptions >= 10){
      settings.liveSearch = true;
    }

    $(this).selectpicker(settings);
  });

  // The dissemination category dropdown has two "Other" options
  // that should reveal a secondary (optional) text input for you
  // to give a short name for the category.
  var showOrHideOtherCategoryInput = function showOrHideOtherCategoryInput(){
    var $select = $('#dissemination_dissemination_category_id');
    var $selectedOption = $select.find(
      'option[value="' + $select.val() + '"]'
    );
    var isOtherCategory = $selectedOption.is('[data-other-category]');

    if(isOtherCategory){
      $('.dissemination_other_category').slideDown(100);
    } else {
      $('.dissemination_other_category').slideUp(100);
    }
  };

  // Hide the other_category input, and give it a better label
  // now that it only ever gets shown by JavaScript.
  $('.dissemination_other_category')
    .hide()
    .find('label').text('Describe the category in a couple of words');

  // Trigger the check on pageload, just in case.
  showOrHideOtherCategoryInput();

  // And then trigger it when the category dropdown is changed.
  $('#dissemination_dissemination_category_id').on('change', function() {
    showOrHideOtherCategoryInput();
  });

  // Submit sorting form automatically on selection of sort option
  $('.list-of-things__sorting').on('changed.bs.select', function() {
    $(this).trigger('submit');
  }).children('.btn-success').hide();

  // Monitor form elements inside the outputs sections and mark each section
  // as 'dirty' if the user changes anything
  var $outputsRadios = $('.output-type-accordion input[type="radio"]');
  // The houdini css works on the next sibling element with a class
  // but it might be immediately adjacent or come after a label for
  // the input we've just selected as 'radio', hence .nextAll()
  $outputsRadios.nextAll('.houdini-target').find(':input').on('change', function() {
    $(this).parents('.houdini-target').addClass('dirty');
    // TODO - what if they delete everything? Ideally we'd reset dirty here,
    // but it's an edge case and they can just click 'ok' to continue anyway
  });

  // Warn people when they fill in one form on the outputs page, and then
  // select another one (because only one will be saved).
  var $currOutput = $outputsRadios.filter(':checked');
  var firstOutputChangeEvent = true;
  $outputsRadios.on('change', function() {
    // If nothing's selected when the page loads, $currOutput will be empty.
    // So, our code won't know where to 'go back' to if the user says cancel
    // in the dialog. This sets that up, for the first click only (after that
    // the code below can handle things).
    if (firstOutputChangeEvent) {
      firstOutputChangeEvent = false;
      if ($currOutput.length === 0) {
        $currOutput = $(this);
      }
    }
    // We only get tiggered after something is checked, so test all the
    // unchecked radios' forms to see if they're dirty
    if ($outputsRadios.not(':checked').nextAll('.dirty').length > 0) {
      var sectionName = $('label[for="' + $currOutput.attr('id') + '"] .output-type-label__title').text();
      var msg = 'Selecting this option will lose the data you\'ve already entered in the ' + sectionName + ' section.\n\nAre you sure you want to change?';
      if (window.confirm(msg)) {
        // Allow the switch to a new checked radio
        $currOutput = $(this);
      } else {
        // Reset the checked radio to the previous one
        console.log('Going back');
        $(this).prop('checked', false);
        $currOutput.prop('checked', true);
      }
    }
  });
});
