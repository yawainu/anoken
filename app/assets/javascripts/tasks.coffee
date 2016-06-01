taskSwitch = (element) ->
  element.children('h4').toggle()
  element.children('.category').toggle()
  element.children('.comment').toggle()
  element.children('.input').toggle()
switching = () ->
  $('.switch').on 'click', ->
    item = $(this).closest('li.item')
    taskSwitch(item)
    if $(this).hasClass('cancel')
      item.find('input[name="name"]').val(item.find('.name').text())
      item.find('[name="category"]').val(item.children('.category').text().trim())
      item.find('textarea[name="comment"]').val(item.children('.comment').val())
$('.submit').on 'click', ->
  field = $(this).closest('.input')
  item = $(this).closest('li.item')
  id = item.attr('id')
  name = field.children('[name=name]').val()
  category = field.children('[name=category]').val()
  comment = field.children('[name=comment]').val()
  params = { _method: 'patch', input: true }
  params['task'] = {
    name: name, category: category, comment: comment
  }
  # XXX 更新ができなくなってる
  $.ajax(
    data: params
    dataType: 'json'
    type: 'POST'
    url: '/tasks/' + id
  ).then (res) ->
    if res.continuable == true
      if res.score
        $('#score').html(res.score)
      if res.task
        item.find('.name').text(res.task.name)
        item.children('.category').html(res.task.category)
        item.children('.comment').html(res.task.comment)
      taskSwitch(item)
    else
      location.href = "/tasks/expired"
$('.box').sortable
  connectWith: '.box'
  forcePlaceholderSize: true
  grid: false
  items: '.item'
  placeholder: 'box-placeholder'
  tolerance: 'pointer'
  update: (e, ui) ->
    item = ui.item
    id = item.attr('id')
    new_state = item.closest('ul').attr('id')
    params = { _method: 'patch' }
    params['task'] = { state: new_state }
    $.ajax(
      data: params
      dataType: 'json'
      type: 'POST'
      url: '/tasks/' + id
    ).then (res) ->
      if res.continuable == true
        if res.score
          $('#score').html(res.score)
      else
        location.href = "/tasks/expired"
switching()
