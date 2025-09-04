<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include "../db.php";

$id = $_POST['id'];
$stmt = $conn->prepare("DELETE FROM users WHERE id=?");
$stmt->bind_param("i", $id);

echo $stmt->execute()
    ? json_encode(["success" => true, "message" => "User deleted successfully"])
    : json_encode(["success" => false, "message" => "Failed to delete user"]);
?>
