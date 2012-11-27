<?php
header("content-type: application/json");


$time = microtime();
$time = explode(' ', $time);
$time = $time[1] + $time[0];
$begintime = $time;

function round_minutes_to_next_half_hour($minutes) {
   return round($minutes / 30) * 30;
}

function round_minutes_to_previous_half_hour($minutes) {
   return $minutes - $minutes % 30;
}

function time_in_minutes($datetime) {
   return $datetime->format('H')*60 + $datetime->format('i');
}

function time_in_minutes_at_previous_half_hour($datetime) {
   return round_minutes_to_previous_half_hour(time_in_minutes($datetime));
}

function time_in_minutes_at_next_half_hour($datetime) {
   return round_minutes_to_next_half_hour(time_in_minutes($datetime));
}

function time_in_month_day($datetime) {
   return $datetime->format('md');
}

$user = "xtvd_app";
$password = "xtvd_pw";
$database = "xtvd";

mysql_connect("localhost",$user,$password);
@mysql_select_db($database) or die("Unable to select database");

$startDateTime = new DateTime;
$guide_duration_in_minutes = 830;

$endDateTime = clone $startDateTime;
$endDateTime->add(new DateInterval("PT".$guide_duration_in_minutes."M"));

$startDate = time_in_month_day($startDateTime);
$startTime = time_in_minutes_at_previous_half_hour($startDateTime);
$endDate = time_in_month_day($endDateTime);
$endTime = time_in_minutes_at_next_half_hour($endDateTime);
$firstChannel = 0;
$lastChannel = 50;

$query = "SELECT b.title, c.callSign, d.channel, b.subtitle, b.description, a.startDate, a.startTime, a.duration
          FROM schedule a 
          INNER JOIN program b ON a.program = b.id 
          INNER JOIN station c ON a.station = c.id
          INNER JOIN map d ON a.station = d.station 
          WHERE ((a.startDate = $endDate AND a.startTime <= $endTime) OR a.startDate < $endDate)
          AND ((a.endDate = $startDate AND a.endTime > $startTime) OR a.endDate > $startDate)
          AND d.channel >= $firstChannel AND d.channel <= $lastChannel 
          ORDER BY d.channel, a.startDate, a.startTime";

$result = mysql_query($query);
$num = mysql_numrows($result);

$listings = array();
while ($row = mysql_fetch_assoc($result))
   $listings[] = $row;

$json = json_encode($listings);

if (isset($_GET['callback'])) 
   echo $_GET['callback'] . '(' . $json . ')';
else 
   echo $json;
?>
