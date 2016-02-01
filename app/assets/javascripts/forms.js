$(function(){
    $('select').each(function(){
        var settings = {}

        // Add a search box, if there are 10 or more options
        var numberOfOptions = $(this).find('option').length;
        if(numberOfOptions >= 10){
            settings.liveSearch = true;
        }

        $(this).selectpicker(settings);
    });
});
