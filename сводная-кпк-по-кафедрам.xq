import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

let $data :=
  fetch:xml(
    'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/7d9b8696-f1be-4abb-9952-2b1947f8193c'
  )
let $tr :=
  for $i in $data//table/row
  let $f := fetch:xml( $i/cell[ @label = 'График КПК']/text() )
  return
  (
    <tr>
      <td class = 'font-weight-bold text-center' colspan = '11'>Кафедра "{ $i/cell[ @label = 'Название кафедры' ]/text() }"</td>
    </tr>,
    for $row in $f//row
    return
      <tr>
      {
        for $cell in $row/cell[ position() > 1 ]
        let $c := 
          if( $cell/@label/data() = ( 'Начало КПК', 'Окончание КПК' ) )
          then( 
          replace(
            xs:string(
              dateTime:dateParse( $cell/text() )
            ),
            '(\d{4})-(\d{2})-(\d{2})',
            '$3.$2.$1'
          ) 
          )
          else(  $cell/text() )
        return
           <td label = "{ $cell/@label/data() }">{ $c  }</td>
      }
      </tr>
  )
  
let $table := 
  <table class="table" >
    <thead class="thead-light">
    <tr>{
      for $i in $tr[ 2 ]/td
      return
        <th>{ $i/@label/data() }</th>
    }</tr>
    </thead>
    { $tr }
  </table>
  
let $site := 
  <html>
    <head>
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous"/>
    </head>
    <body>
      <div class = 'container'>
        <nav class="navbar navbar-light bg-light">
          <a class="navbar-brand" href="https://unoi.ru/">
            <img src="https://thumb.tildacdn.com/tild6337-3765-4231-b434-666537306166/-/resize/59x/-/format/webp/image_1__2_-removebg.png" width="30" height="30" class="d-inline-block align-top" alt=""/>
            <span style = "color: #04b8ac;">УНИВЕРСИТЕТ НЕПРЕРЫВНОГО ОБРАЗОВАНИЯ И ИННОВАЦИЙ</span>
          </a>
        </nav>
        <div class = 'h1' style = "color: #04b8ac;">Курсы повышения квалификации по кафедрам</div>
        { $table }
      </div>
    </body>
  </html>

return
  (
    $site, 
    file:write( "C:\Users\kontu\Desktop\УНОИ-КПК.html", $site )
  )