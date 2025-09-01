<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include "../db.php";

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    exit;
}

// Get POST data
$id = $_POST['id'] ?? '';
$username = $_POST['username'] ?? null;
$password = $_POST['password'] ?? null;
$role = $_POST['role'] ?? null;
$status = $_POST['status'] ?? null;
$loggedInUsername = $_POST['loggedInUsername'] ?? '';

// Validate ID
if (empty($id)) {
    echo json_encode(['success' => false, 'message' => 'ID required']);
    exit;
}

// Prepare fields for update
$fields = [];
$params = [];
$types = '';

// Only update username if provided
if ($username !== null && $username !== '') {
    $fields[] = "username = ?";
    $params[] = $username;
    $types .= 's';
}

// Only update password if provided
if ($password !== null && $password !== '') {
    $fields[] = "password = ?";
    $params[] = password_hash($password, PASSWORD_DEFAULT);
    $types .= 's';
}

// Only update role if provided
if ($role !== null) {
    // Only first admin can assign 'admin' role
    if ($role === 'admin' && $loggedInUsername !== 'admin') {
        echo json_encode(['success' => false, 'message' => 'Only the first admin can assign admin role']);
        exit;
    }
    $fields[] = "role = ?";
    $params[] = $role;
    $types .= 's';
}

// Only update status if provided
if ($status !== null) {
    $fields[] = "status = ?";
    $params[] = $status;
    $types .= 's';
}

// Nothing to update
if (count($fields) === 0) {
    echo json_encode(['success' => false, 'message' => 'Nothing to update']);
    exit;
}

// Build SQL
$sql = "UPDATE users SET " . implode(", ", $fields) . " WHERE id = ?";
$params[] = $id;
$types .= 'i';

$stmt = $conn->prepare($sql);
$stmt->bind_param($types, ...$params);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'User updated successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error updating user']);
}

$conn->close();
?>
