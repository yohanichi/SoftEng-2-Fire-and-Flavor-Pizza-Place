<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
include "db.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'] ?? '';
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    $role = $_POST['role'] ?? 'user';

    if (empty($id) || empty($username)) {
        echo json_encode(['success' => false, 'message' => 'ID and username required']);
        exit;
    }

    // Check if username already exists for a different user
    $stmtCheck = $conn->prepare("SELECT id FROM users WHERE username=? AND id<>?");
    $stmtCheck->bind_param("si", $username, $id);
    $stmtCheck->execute();
    $stmtCheck->store_result();
    if ($stmtCheck->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Username already exists!']);
        exit;
    }

    if (!empty($password)) {
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $sql = "UPDATE users SET username=?, password=?, role=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sssi", $username, $hashed_password, $role, $id);
    } else {
        $sql = "UPDATE users SET username=?, role=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssi", $username, $role, $id);
    }

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'User updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Error updating user']);
    }
}