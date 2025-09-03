<?php
header("Content-Type: application/json");
include("../db.php");

$id = $_POST['id'] ?? '';
$status = $_POST['status'] ?? '';

if ($id == '' || $status == '') {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
    exit;
}

$stmt = $conn->prepare("UPDATE raw_materials SET status=? WHERE id=?");
$stmt->bind_param("si", $status, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Status updated"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update status"]);
}

$conn->close();
?>
