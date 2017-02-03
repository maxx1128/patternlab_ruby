
// Containerization for each individual alert
function sg_tabs($, patternId) {
  
  var pattern;

  function init() {
    pattern.attr('gs-init','');


    pattern.find('.sg-tabs__link:first-of-type').addClass('sg-tabs__link--active');

    pattern.find('.sg-tabs__content-item:first-of-type').addClass('sg-tabs__content-item--active');
  }
  
  function setEvents() {
    pattern.on('click', '.sg-tabs__link', function(){

      var selected_id = $(this).attr('tabs-link-id');

      pattern.find('.sg-tabs__link').removeClass('sg-tabs__link--active');
      $(this).addClass('sg-tabs__link--active');

      pattern.find('.sg-tabs__content-item').each(function(){

        var content_id = $(this).attr('tabs-content-id');

        content_id == selected_id ? $(this).addClass('sg-tabs__content-item--active') : $(this).removeClass('sg-tabs__content-item--active')

      });
    });
  }

  function docReady() {
    pattern = $("#" + patternId);
    init();
    setEvents();
  }
  
  return docReady;
}


var SG_TABS_EXT = {
  
  "init":function(){
    $('.sg-tabs').each(function() {

      id = $(this).attr('id');

      if ( id === undefined ) {
        
        var
          id_num = 1 + Math.floor(Math.random() * 999999999),
          id     = 'UNIQUE_ID_' + id_num
        ;

        $(this).attr('id', id);
      }      

      sg_tabs(jQuery, id)();
    });
  }
}