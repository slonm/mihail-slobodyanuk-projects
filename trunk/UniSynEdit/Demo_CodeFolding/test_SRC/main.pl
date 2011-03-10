#!/usr/bin/perl
# Подключаем основные модули
use strict;
use warnings;
use CGI qw(:standard :html3);
use CGI::Cookie;
use DBI;
use Storable;
use vars '$dbh', '%user_vars';

my $CookieSessionID;

# Отсылаем заголовок браузеру
#print "Content-type: text/html; charset=windows-1251\r\n\r\n";


# Определяем IP адрес пользователя (первые две цифры)
$user_vars{'remote_addr'} = $ENV{'REMOTE_ADDR'} || 'empty'; 

$user_vars{'remote_addr'} =~s /^(\d+)\.(\d+)\.\d+\.\d+$/$1\.$2/; 

$user_vars{'remote_addr'} = 'empty' unless $user_vars{'remote_addr'}; 

$user_vars{'remote_host'} = $ENV{'REMOTE_HOST'} || 'empty'; 

$user_vars{'remote_host'} = quotemeta $user_vars{'remote_host'}; 

$user_vars{'forwarded'} = $ENV{'HTTP_X_FORWARDED_FOR'} || 'empty'; 

$user_vars{'forwarded'} = quotemeta $user_vars{'forwarded'}; 



# Подключаемся к базе данных
$dbh = 'DBI'->connect('DBI:mysql:database=EventsLogs; host=localhost; port=3306', 'root', 'Nitsche1')             || die $DBI::errstr; 

# Получаем Cookies пользователя
my %cookies = fetch CGI::Cookie;

# Проверяем параметр session в Cookies
if ($cookies{'session'}) {
    # Выбираем значение параметра session    
    $cookies{'session'} = $cookies{'session'}->value;
    $cookies{'session'} =~s /[\W]//g;     

    $cookies{'session'} = 'empty' unless $cookies{'session'}; 


# Проверяем наличие сессии    
  my $sth = $dbh->prepare('SELECT t1.user,                                    
t1.host,                                    
t1.ip,                                    
t1.forwarded,                                    
t2.name                             
FROM session AS t1,                                 
users AS t2                             
WHERE t1.session = \''.$cookies{'session'}.'\' AND                                
 t1.user = t2.id                             
LIMIT 1');     

  $sth->execute();          

  my $session = $sth->fetchrow_hashref();     

  $sth->finish();  

  # Если сессия есть и она не гостевая    
  if ($session && $session > 0 && $$session{'user'} != 4) 
  {
    #-- Проверяем сессию по IP, хосту и прокси серверу пользователя        
#    if ($$session{'ip'} ne $user_vars{'remote_addr'} ||
#                $$session{'host'} ne $user_vars{'remote_host'} ||
#                $$session{'forvarded'} ne $user_vars{'forvarded'}) 
#    {
#            &create_session;
#            &show_authorize_form;
#         
#    }

    #-- Обновляем время сессии        
    &update_session($cookies{'session'}); 

    #-- Выводим форму приветсвия         
    &show_welcome_form($session); 

    # Если сессия есть и она гостевая    
  } elsif ($session && $session > 0 && $$session{'user'} == 4) 
  {

    #-- Обновляем время сессии
    &update_session($cookies{'session'}); 
    #-- Выводим форму авторизации
    &show_authorize_form; 

  # Если сессии нет    
} else {
  #-- Обращаемся к процедуре создания сессии         
  &create_session; 
  #-- Выводим форму авторизации         
  &show_authorize_form;     
  }
} else {
  #-- Обращаемся к процедуре создания сессии     
  &create_session; 

  #-- Выводим форму авторизации    
  &show_authorize_form; 
}
exit; 

################################################################################# Процедура создания сессии
sub create_session {

# Объявляем переменную новой сессии    
my $session; # Массив символов для ключа    
my @rnd_txt = ('0','1','2','3','4','5','6','7','8','9',
                 'A','a','B','b','C','c','D','d','E','e',
                 'F','f','G','g','H','h','I','i','J','j',
                 'K','k','L','l','M','m','N','n','O','o',
                 'P','p','R','r','S','s','T','t','U','u',
                 'V','v','W','w','X','x','Y','y','Z','z');
     srand; # Генерим ключ
     for (0..31) {
        my $s = rand(@rnd_txt);
         $session .= $rnd_txt[$s]
    }


  # Добавляем запись в таблицу сессий    
  $dbh->do('INSERT INTO session
             SET session = \''.$session.'\',
                 user = 4,
                 time = '.time.',
                 host = \''.$user_vars{'remote_host'}.'\',
                 ip = \''.$user_vars{'remote_addr'}.'\',
                 forwarded = \''.$user_vars{'forwarded'}.'\'');

  # Определяем код для установки Cookies
  # В связи с тем, что скрипт внедряется через SSI, то передача Cookies в заголовке никакого
  # еффекта не произведет, т.к. на странице уже заголовки отправлены и приняты, поэтому Cookies
  # устанавливаются с помощью JavaScript, иначе же мы просто бы добавили в заголовок строку:
  # "Set-Cookie: session=$session;  expires=Friday, 25-Dec-2020 23:59:59 GMT;path=/;    domain=mydomain.ru; \n"

  # соответсвенно mydomain.ru меняем на свой домен    
#  $user_vars{'cookies'} = '<SCRIPT LANGUAGE="JavaScript">this.document.cookie="session='.$session.
#                            '; path=/; domain=localhost; expires=Sunday,31-Dec-19 23:59:59 GMT; "; </SCRIPT>
#                            <SCRIPT LANGUAGE="JavaScript">this.document.cookie="session='.$session.
#                            '; path=/; domain=localhost; expires=Sunday,31-Dec-19 23:59:59 GMT; "; </SCRIPT>'; 

  $CookieSessionID = new CGI::Cookie(-name => 'session',
      -value => $session,
      -expires => '+3M',
  );  

  # Создаем дапм хеша с одним элементом name    
  store {name => 'Guest'}, './data/'.$session;
     return 1; 
}
################################################################################# Процедура обновления сессии
sub update_session {
    my $session = shift;
     $dbh->do('UPDATE session SET time = '.time.' WHERE session = \''.$session.'\' LIMIT 1');
     return 1; 
}

################################################################################# Процедура вывода формы авторизации
sub show_authorize_form {
  # Выводим (или не выводим) код установки Cookies    
#  print $user_vars{'cookies'} if exists $user_vars{'cookies'}; 

# Отсылаем заголовок браузеру
  print header(
        -type    => 'text/html; charset=windows-1251',
        -cookie  => [$CookieSessionID]
        );

  # Выводим форму авторизации     
  print '<table width=150 border=0>
             <form action="http://localhost/Event/login.pl" method=post>
             <tr><td>
                 Login:<input type="text" name="login" size=10><br>
                 Password:<input type="password" name="pass" size=10>
                    <input type="submit" name="submit" value="Войти" size=10>
             </td></tr>
             </form>
            </table>';
     exit; 
}

################################################################################# Процедура вывода формы приветсвия
sub show_welcome_form {
  print header(
        -type    => 'text/html; charset=windows-1251'
        );

    my $user = shift;
     print '<table width=150 border=0>
             <tr><td>
                 Вы зашли как '.$$user{'name'}.'<br>
                 <a href="http://localhost/Event/logout.pl">Выйти</a>
             </td></tr>
         </table>';
     exit; }
1; 
