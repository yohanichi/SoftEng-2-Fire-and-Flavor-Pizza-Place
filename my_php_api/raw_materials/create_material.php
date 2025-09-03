<?php
header("Content-Type: application/json");
include("../db.php");

$name = $_POST['name'] ?? '';
$quantity = $_POST['quantity'] ?? '';
$type = $_POST['type'] ?? 'weight';
$unit = $_POST['unit'] ?? 'kg';

if ($name == '' || $quantity == '') {
    echo json_encode(["success" => false, "message" => "Name and quantity required"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO raw_materials (name, quantity, type, unit) VALUES (?, ?, ?, ?)");
$stmt->bind_param("sdss", $name, $quantity, $type, $unit);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Material added successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Insert failed"]);
}

$conn->close();
?>
