import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function local:date( $var ){
  replace(
      xs:string(
        dateTime:dateParse( $var )
      ),
      '(\d{4})-(\d{2})-(\d{2})',
      '$3.$2.$1'
    ) 
};

declare function local:ifNotEmpty( $str, $var ){
    if( $var )
    then( ( $str, <div>{ $var }</div> ) )
    else()
  };

declare function local:table( $i ){
  <table class = "table table-bordered">
        <thead>
          <tr class = 'text-center'>
            <th class = 'align-middle'>Категория слушателей</th>
            <th class = 'align-middle'>Название дополнительной профессиональной программы, аннотация</th>
            <th class = 'align-middle'>Объем программы, час</th>
            <th class = 'align-middle'>Сроки обучения, час.</th>
            <th class = 'align-middle'>Стоимость, рублей</th>
            <th class = 'align-middle'>Руководитель курсов</th>
          </tr>
        </thead>
        <tbody>
          {
          for $j in $i
          return
            <tr>
              <td>{ $j/cell[ @label = 'Целевая категория']/text() }</td>
              <td>
                <b><i>{ $j/cell[ @label = 'Название ДПП']/text() }</i></b><br/>
                {
                  local:ifNotEmpty(
                    <b>В программе:</b>,
                   $j/cell[ @label = 'В программе']/text()
                  )
                }
                {
                  local:ifNotEmpty(
                    <b>Результат обучения:</b>,
                    $j/cell[ @label = 'В результате обучения']/text()
                  )
                }
                {
                  local:ifNotEmpty(
                    <b>Итоговая аттестация:</b>,
                    $j/cell[ @label = 'Итоговая аттестация']/text()
                  )
                }
                {
                  (
                    <b>Кафедра:</b>,
                    <div>{ lower-case( $j/cell[ @label = 'Кафедра' ]/text() ) }</div>
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Объем']/text() }</td>
              <td class = 'text-center'>
                { local:date( $j/cell[ @label = 'Начало КПК']/text() ) }-
                { local:date( $j/cell[ @label = 'Окончание КПК']/text() ) }
                {
                  local:ifNotEmpty(
                    <div>Очный этап:</div>,
                    $j/cell[ @label = 'Дни очного обучения']/text()
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Стоимость обучения']/text() }</td>
              <td>{ $j/cell[ @label = 'Руководитель КПК']/text() }</td>
            </tr>
          }
        </tbody>
      </table>
};

let $date := 
  function ( $var ){
    replace(
      xs:string(
        dateTime:dateParse( $var )
      ),
      '(\d{4})-(\d{2})-(\d{2})',
      '$3.$2.$1'
    ) 
  }

let $ifempty :=
  function( $str, $var ){
    if( $var )
    then( ( $str, <div>{ $var }</div> ) )
    else()
  }

let $data := .

let $виды := $data//table[ @label = 'ДПО' ]
let $уровни := $data//table[ @label = 'Уровни' ]
let $кафедры := $data//table[ @label = 'Кафедры' ]
let $курсы :=
  for $i in $кафедры/row
  let $path := $i/cell[ @label = 'График КПК' ]/text()
  let $КПК := fetch:xml( $path )//row
  return
    $КПК update insert node <cell label = 'Кафедра'>{ $i/cell[ @label = 'Название кафедры' ]/text() }</cell> into .

let $содержание :=
  for $i in $курсы
  let $вид := 
    let $часов :=
      xs:integer( 
        let $ч := 
          if( $i/cell[ @label = 'Объем' ]/text() != '' )
          then( $i/cell[ @label = 'Объем' ]/text() )
          else( '0' )
        return
          replace( tokenize( $ч, ',' )[ last() ] , '\D', '' )
        )
    return
      if( $часов >= 256 )
      then( 'Профессиональная переподготовка' )
      else( 
        if( $часов >= 16 )
        then( 'Курсы повышения квалификации' )
        else( 'Консультации' )
      )
 
  group by $вид
  
  return
    <div>
      <h2>{ upper-case( $вид ) }</h2>
      <div>{
        for $k in $i
         let $уровень := $k/cell[ @label = 'Уровень' ]/text()
         group by $уровень
         let $названиеУровня :=
           let $l :=
             $уровни/row[ cell[ @label = 'Сокращенное название'] = $уровень ]
             /cell[ @label = 'Название']/text()
           return
             if( $l != '' )then( $l )else( $уровень )
            
        return
          <div>
            <h3>{ $названиеУровня }</h3>
            <div>{ local:table( $k ) }</div>
          </div>
      }</div>
    </div>
    
return
  <html>
    <head>
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous"/>
    </head>
    <body>
      <div class = 'container'>
        <nav class="navbar navbar-light bg-light">
          <a class="navbar-brand" href="http://iro37.ru/res/trac-src/xqueries/unoi/unoi-test.html">
            <img src="http://iro37.ru/res/trac-src/xqueries/unoi/image/logoUnoi.jpg" width="180" height="100" class="d-inline-block align-top" alt=""/>
            <img src="http://iro37.ru/res/trac-src/img/logo.jpg" width="110" height="100" class="d-inline-block align-top" alt=""/>
            <span style = "color: #04b8ac;">УНИВЕРСИТЕТ НЕПРЕРЫВНОГО ОБРАЗОВАНИЯ И ИННОВАЦИЙ</span>
          </a>
        </nav>
        <div id = 'content'>
          <div class = 'h1' style = "color: #04b8ac;">Календарный план</div>
          { $содержание }
        </div>
      </div>
    </body>
  </html>