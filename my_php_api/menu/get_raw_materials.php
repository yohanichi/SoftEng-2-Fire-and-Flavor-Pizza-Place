<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

include("../db.php");

try {
    // Modify query to fetch 'id', 'name', and 'unit' from the raw_materials table
    $result = $conn->query("SELECT id, name, unit FROM raw_materials ORDER BY name ASC");
    $materials = [];

    while ($row = $result->fetch_assoc()) {
        $materials[] = $row;
    }

    // Return data including the 'unit' for each raw material
    echo json_encode(['success' => true, 'data' => $materials]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
