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

    // Trigger the check on pageload, just in case.
    showOrHideOtherCategoryInput();

    // And then trigger it when the category dropdown is changed.
    $('#dissemination_dissemination_category_id').on('change', function(e){
        showOrHideOtherCategoryInput();
    });

    // Hide the other_category input, and give it a better label
    // now that it only ever gets shown by JavaScript.
    $('.dissemination_other_category').hide()
        .find('label').text('Describe the category in a couple of words');
});
