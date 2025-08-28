<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Connect DB
$conn = new mysqli("sql100.infinityfree.com", "if0_39810463", "wxt7a0JHwgI", "if0_39810463_testdb");
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "DB connection failed"]);
    exit;
}

// Query all users
$sql = "SELECT id, username, role FROM users";
$result = $conn->query($sql);

$users = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

echo json_encode([
    "success" => true,
    "users" => $users
]);

$conn->close();
?>
