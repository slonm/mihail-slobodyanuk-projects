<?php  
include 'dbdata.php';  
  
if($_POST)  
{  
    $black_list = mysql_query("SELECT * FROM `IP_Black_List` WHERE `ip`='".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."' LIMIT 1");  
    $row = mysql_fetch_assoc($black_list);  
    if(!$row || $row['try']<7)  
    {  
    //���� IP � ���� ����� ��� ��� ���-�� ������� �� ������ 7, ��������� ����� � ������.  
        $user_name = addslashes(htmlspecialchars(substr(trim($_POST['name']),0,14)));  
        $user_password = addslashes(htmlspecialchars(substr(trim($_POST['password']),0,14)));  
        $auth = "SELECT * FROM `User` WHERE `name`='".mysql_real_escape_string($user_name)."' AND `password`='".mysql_real_escape_string($user_password)."' LIMIT 1";  
        $result_auth = mysql_query($auth);  
        $row_auth = mysql_fetch_assoc($result_auth);  
        if($row_auth)  
        {  
            session_start();  
            echo $_SESSION['ip'] = $_SERVER['REMOTE_ADDR']. '**' .$_SESSION['id'] = session_id();  
            mysql_query("DELETE FROM `IP_Black_List` WHERE `ip`='".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."'");  
        }  
        else if(!$row)  
        {  
    //����������� �� ������. ���� ������ IP ��� ���, ���������� � ���� ����  
            $date = date("Y-m-d");  
            mysql_query("INSERT INTO `IP_Black_List` (`id`,`ip`,`try`,`date`)VALUES('','".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."','1','".mysql_real_escape_string($date)."')");  
            echo 'Fuck**�������� ��� ��� ������. � ��� �������� 6 �������.';exit;  
        }  
        else  
        {  
    //����������� �� ������. IP ��� ���� - ��������� � ���� ���� �������  
            $row['try']++;  
            mysql_query("UPDATE `IP_Black_List` set `try`='".mysql_real_escape_string($row['try'])."' WHERE (`ip`='".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."')");  
            switch ($row['try']) {  
              case 2:$b="5 �������"; break;  
              case 3:$b="4 �������"; break;  
              case 4:$b="3 �������"; break;  
              case 5:$b="2 �������"; break;  
              case 6:$b="1 �������"; break;  
              case 7:$b="��� IP ����� ������������"; break;  
            }  
            if($row['try']!==7)  
            {  
                echo 'Fuck**�� ������ ��� ��� ������. � ��� �������� '.$b;  
            }  
            else  
            {  
                echo 'Fuck**'.$b;  
            }  
        }  
    }  
    else if($row>6)  
    {  
    //���� ���-�� ������� ������ 7 - �����.  
        echo 'Fuck**��� IP ����� ������������'; exit;  
    }  
}  
else  
{  
// ���� POST'� ������ - ���������� �� �����������  
    header("Location: http://".$_SERVER['HTTP_HOST'].dirname($_SERVER['PHP_SELF']));  
}  
mysql_close($link);  
