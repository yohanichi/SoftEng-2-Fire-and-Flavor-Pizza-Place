<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include "db.php";

$username = $_POST['username'];
$password = $_POST['password'];

$stmt = $conn->prepare("SELECT * FROM users WHERE username=?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    if (password_verify($password, $row['password'])) {
        $role = isset($row['role']) ? $row['role'] : "user"; // ✅ fallback

        echo json_encode([
          "success" => true,
          "message" => "Login successful",
          "username" => $row['username'],
          "role" => $row['role']
        ]);

    } else {
        echo json_encode([
            "success" => false,
            "message" => "Invalid password"
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "User not found"
    ]);
}
?>
