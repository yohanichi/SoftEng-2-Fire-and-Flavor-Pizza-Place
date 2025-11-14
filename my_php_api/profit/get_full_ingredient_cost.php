<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include("../db.php"); // your DB connection

$menuName = $conn->real_escape_string($_GET['name'] ?? '');

if (empty($menuName)) {
    echo json_encode([
        "success" => false,
        "ingredient_cost" => 0,
        "breakdown" => [],
        "message" => "Menu name is required"
    ]);
    exit;
}

// --- 1. Get menu ID ---
$menuIdQuery = $conn->prepare("SELECT id FROM menu_items WHERE name = ? LIMIT 1");
$menuIdQuery->bind_param("s", $menuName);
$menuIdQuery->execute();
$menuIdResult = $menuIdQuery->get_result();

if ($menuIdResult->num_rows === 0) {
    echo json_encode([
        "success" => false,
        "ingredient_cost" => 0,
        "breakdown" => [],
        "message" => "Menu not found"
    ]);
    exit;
}

$menuId = $menuIdResult->fetch_assoc()['id'];

// --- 2. Get ingredients with nearest expiration date cost ---
$ingredientsQuery = $conn->prepare("
    SELECT mi.material_id, mi.quantity AS recipe_qty, rm.name AS ingredient_name,
           (
               SELECT il.cost
               FROM inventory_log il
               WHERE il.material_id = mi.material_id
                 AND il.expiration_date >= CURDATE()  -- only non-expired stock
               ORDER BY il.expiration_date ASC
               LIMIT 1
           ) AS nearest_exp_cost
    FROM menu_ingredients mi
    LEFT JOIN raw_materials rm ON mi.material_id = rm.id
    WHERE mi.menu_id = ?
");
$ingredientsQuery->bind_param("i", $menuId);
$ingredientsQuery->execute();
$ingredientsResult = $ingredientsQuery->get_result();

$totalCost = 0;
$breakdown = [];

while ($row = $ingredientsResult->fetch_assoc()) {
    $recipeQty = (float)$row['recipe_qty'];
    $ingredientCost = (float)$row['nearest_exp_cost']; // cost from nearest exp date
    $ingredientName = $row['ingredient_name'] ?? "Unknown";

    $costPerIngredient = $recipeQty * $ingredientCost;
    $totalCost += $costPerIngredient;

    $breakdown[] = [
        "name" => $ingredientName,
        "cost" => $costPerIngredient,
        "quantity" => $recipeQty
    ];
}

echo json_encode([
    "success" => true,
    "ingredient_cost" => $totalCost,
    "breakdown" => $breakdown
]);
?>
