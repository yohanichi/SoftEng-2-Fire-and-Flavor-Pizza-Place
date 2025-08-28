<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "sql100.infinityfree.com";
$user = "if0_39810463"; // change if needed
$pass = "wxt7a0JHwgI";     // change if needed
$db   = "if0_39810463_testdb";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
