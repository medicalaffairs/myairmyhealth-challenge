// these things happen on every page referenced by common.js
$(document).ready(function() {
 
    if ( !("placeholder" in document.createElement("input")) ) {
        $("input[placeholder][type='text'], textarea[placeholder]").each(function() {
            var val = $(this).attr("placeholder");
            if ( $(this).val() == "" ) {
                $(this).addClass('placeholder');
                $(this).val(val);
            }
            $(this).focus(function() {
                if ( $(this).val() == val ) {
                    $(this).val('');
                    $(this).removeClass('placeholder');
                }
            }).blur(function() {
                if ( $.trim($(this).val()) == "" ) {
                    $(this).addClass('placeholder');
                    $(this).val(val);
                }
            })
        });
 
        // Clear default placeholder values on form submit
        $('form').submit(function() {
            $(this).find("input[placeholder], textarea[placeholder]").each(function() {
                if ( $(this).val() == $(this).attr("placeholder") ) {
                    $(this).val('');
                }
            });
        });
    }
});