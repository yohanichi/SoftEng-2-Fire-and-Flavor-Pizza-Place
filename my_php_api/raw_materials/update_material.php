<?php
header("Content-Type: application/json");
include("../db.php");

$id = $_POST['id'] ?? '';
$name = $_POST['name'] ?? '';
$quantity = $_POST['quantity'] ?? '';
$type = $_POST['type'] ?? '';
$unit = $_POST['unit'] ?? '';

if ($id == '' || $name == '' || $quantity == '') {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

$stmt = $conn->prepare("UPDATE raw_materials SET name=?, quantity=?, type=?, unit=? WHERE id=?");
$stmt->bind_param("sdssi", $name, $quantity, $type, $unit, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Material updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Update failed"]);
}

$conn->close();
?>
