<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
include "db.php";

$username = $_POST['username'];
$password = $_POST['password'];

if ($username == "" || $password == "") {
    echo json_encode(["success" => false, "message" => "All fields required"]);
    exit;
}

// hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// insert
$sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'user')";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $username, $hashedPassword);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Registration successful"]);
} else {
    echo json_encode(["success" => false, "message" => "Username already exists"]);
}

$stmt->close();
$conn->close();
?>
