<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include("../db.php");

$menuName = $conn->real_escape_string($_GET['name']);

// Get menu ID
$menuIdQuery = $conn->prepare("SELECT id FROM menu_items WHERE name = ? LIMIT 1");
$menuIdQuery->bind_param("s", $menuName);
$menuIdQuery->execute();
$menuIdResult = $menuIdQuery->get_result();

if ($menuIdResult->num_rows === 0) {
    echo json_encode(["success" => false, "ingredient_cost" => 0]);
    exit;
}

$menuId = $menuIdResult->fetch_assoc()['id'];

// Get ingredients for this menu item
$ingredientsQuery = $conn->prepare("
    SELECT mi.quantity AS recipe_qty,
           (
               SELECT il.cost
               FROM inventory_log il
               WHERE il.material_id = mi.material_id
               ORDER BY il.id DESC
               LIMIT 1
           ) AS latest_cost
    FROM menu_ingredients mi
    WHERE mi.menu_id = ?
");
$ingredientsQuery->bind_param("i", $menuId);
$ingredientsQuery->execute();
$ingredientsResult = $ingredientsQuery->get_result();

$totalCost = 0;

while ($row = $ingredientsResult->fetch_assoc()) {
    $recipeQty = (float)$row['recipe_qty'];
    $latestCost = (float)$row['latest_cost'];

    if ($latestCost > 0) {
        $totalCost += $recipeQty * $latestCost;
    }
}

echo json_encode([
    "success" => true,
    "ingredient_cost" => $totalCost
]);
