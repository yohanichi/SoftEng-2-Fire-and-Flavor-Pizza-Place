<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include "db.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'] ?? '';
    $status = $_POST['status'] ?? '';

    if (empty($id) || !in_array($status, ['active', 'blocked'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid user ID or status'
        ]);
        exit;
    }

    // Optional: prevent blocking first admin
    if ($id == 1) {
        echo json_encode([
            'success' => false,
            'message' => 'Cannot block the first admin'
        ]);
        exit;
    }

    $stmt = $conn->prepare("UPDATE users SET status=? WHERE id=?");
    $stmt->bind_param("si", $status, $id);

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => "User status updated to $status"
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update user status'
        ]);
    }
}
?>
