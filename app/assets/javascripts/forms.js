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

  // Checks the active output type section for altered inputs,
  // and if found, disables the other sections, so you can't submit
  // data in multiple sections at the same time.
  var updateOutputTypeAccordion = function updateOutputTypeAccordion(){
    var $section = $('.output-type-input:checked').next().next(); // get the 'houdini-target'
    var $inputs = $section.find('textarea:visible, input[type="text"]:visible');
    var sectionIsDirty = false;
    $inputs.each(function(){
      if( $.trim($(this).val()) !== '' ){
        sectionIsDirty = true;
      }
    });
    if(sectionIsDirty){
      $section.siblings('.action-sheet__section').each(function(){
        $(this).prev().prev().prop('disabled', true);
      });
    } else {
      $section.siblings('.action-sheet__section').each(function(){
        $(this).prev().prev().removeProp('disabled');
      });
    }
  }

  $('.output-type-accordion .action-sheet__section').on('keyup change', updateOutputTypeAccordion);

});
