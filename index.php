<?php
# startTime:
#    now:
#    [-|+]?[0-9]+ The offset from now in minutes
$user = "xtvd_app";
$password = "xtvd_pw";
$database = "xtvd";

# common SQL strings
$sql_startTime = 'DATE_ADD(a.time, INTERVAL -8 HOUR)';
$sql_endTime   = 'DATE_ADD(DATE_ADD(a.time, INTERVAL -8 HOUR), INTERVAL a.duration MINUTE)';
$sql_time_format = 'Y-m-d H:i:s';

mysql_connect("localhost",$user,$password);
@mysql_select_db($database) or die("Unable to select database");

$time = new DateTime;
if (isset($_GET['startTimeOffset']))
{
   $time = date_add($time, new DateInterval($_GET['startTimeOffset']));
}
$time_fmt = $time->format($sql_time_format);

$startLimit = 0;
if (isset($_GET['startLimit'])){
   $startLimit = $_GET['startLimit'];
}

$endLimit = 100;
if (isset($_GET['endLimit'])){
   $endLimit = $_GET['endLimit'];
}

if (isset($_GET['channel']))
{
   # if a channel is selected then we want to
   # get 6 hours of programming

   $time_plus_24 = date_add($time, new DateInterval("P1D"));
   $time_plus_24_fmt = $time_plus_24->format($sql_time_format);

   $range = "(('$time_fmt' >= $sql_startTime AND '$time_fmt' <= $sql_endTime)
             OR ($sql_startTime <= '$time_plus_24_fmt' AND $sql_endTime >= '$time_fmt'))";
   $channel_filter = "AND d.channel = ".$_GET['channel'];
   $order = 'ORDER BY a.time';
   $limit = 'LIMIT 0, 10';
}
else
{
   $range = "('$time_fmt' >= $sql_startTime AND '$time_fmt' <= $sql_endTime)";
   $channel_filter = "AND d.channel >= $startLimit AND d.channel <= $endLimit";
   $order = 'ORDER BY d.channel';
   $limit = '';
}

# This query is used when trying o get 
$query = "SELECT b.title, c.callSign, d.channel, b.subtitle, b.description, 
                 DATE_FORMAT($sql_startTime, '%l:%i%p') AS start,
                 DATE_FORMAT($sql_endTime, '%l:%i%p') AS end
          FROM schedule a 
          INNER JOIN program b ON a.program = b.id 
          INNER JOIN station c ON a.station = c.id
          INNER JOIN map d ON a.station = d.station 
          WHERE $range $channel_filter
          $order
          $limit";


$result = mysql_query($query);
$num = mysql_numrows($result);

$listing = array();
$i=0;
while ($i < $num){
   $channel = array();
   $channel['title'] =  mysql_result($result, $i, "title");
   $channel['callSign'] = mysql_result($result, $i, "callSign");
   $channel['number'] = mysql_result($result, $i, "channel");
   $channel['subtitle'] = mysql_result($result, $i, "subtitle");
   $channel['description'] = mysql_result($result, $i, "description");
   $channel['start'] = mysql_result($result, $i, "start");
   $channel['end'] = mysql_result($result, $i, "end");
   $listing[$i] = $channel;
   $i++;
}

echo json_encode($listing);
?>
