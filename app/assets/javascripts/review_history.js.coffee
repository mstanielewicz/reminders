$('document').ready ->
  $('tbody.review_history').hide()
  $('.toggle_history').on 'click', ->
    expandable_class = $(this).parent('td').attr('class')
    $('tbody.review_history.' + expandable_class).slideToggle('slow')
