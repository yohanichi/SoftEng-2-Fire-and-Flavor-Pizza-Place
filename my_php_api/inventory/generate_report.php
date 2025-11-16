<?php
require('fpdf/fpdf.php');
include '../db.php';

class PDF extends FPDF
{
    function Header()
    {
        // Set grey background for header
        $this->SetFillColor(200, 200, 200); // RGB values for grey

        // Set font for the header
        $this->SetFont('Arial', 'B', 12);  // Smaller font size for the header

        // Title
        $this->Cell(0, 10, 'Inventory Report', 0, 1, 'C', 0, '', true);
        
        $this->Ln(5); // Line break

        // Add the "Generated on" text below the title
        $this->SetFont('Arial', 'I', 10); // Italic style for "Generated on"
        $this->Cell(0, 10, 'Generated on ' . date('m/d/Y h:iA'), 0, 1, 'C');
        $this->Ln(5); // Line break after "Generated on" text

        // Column headers
        $this->SetFont('Arial', 'B', 10);  // Smaller font size for column headers
        $this->Cell(40, 10, 'Material Name', 1, 0, 'C', 1);  // Adjusted column width
        // Wider column for Quantity
        $this->Cell(30, 10, 'Quantity', 1, 0, 'C', 1);  
        $this->Cell(20, 10, 'Type', 1, 0, 'C', 1);
        $this->Cell(20, 10, 'Unit', 1, 0, 'C', 1);
        $this->Cell(30, 10, 'Restock Level', 1, 0, 'C', 1);  // Adjusted column width
        $this->Cell(40, 10, 'Last Updated', 1, 1, 'C', 1);
    }

    function Footer()
    {
        // Footer with page number (if needed)
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo(), 0, 0, 'C');
    }
}

$pdf = new PDF();
$pdf->AddPage();
$pdf->SetFont('Arial', '', 9); // Reduced font size for the table content

$query = "SELECT name, quantity, type, unit, restock_level, created_at FROM raw_materials WHERE status = 'visible'";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Format the quantity with commas for thousands
        $formattedQuantity = number_format($row['quantity']);

        // Format the 'created_at' field to MM/dd/yyyy 10:30AM format
        $date = new DateTime($row['created_at']);
        $formattedDate = $date->format('m/d/Y h:iA');  // Example: 10/30/2025 10:30AM

        // Format the Restock Level (if needed)
        $formattedRestockLevel = number_format($row['restock_level']);

        // Insert data into the table with adjusted widths
        $pdf->Cell(40, 10, $row['name'], 1);  // Adjusted width for Material Name
        $pdf->Cell(30, 10, $formattedQuantity, 1, 0, 'C'); // Widened Quantity column
        $pdf->Cell(20, 10, ucfirst($row['type']), 1, 0, 'C');
        $pdf->Cell(20, 10, $row['unit'], 1, 0, 'C');
        $pdf->Cell(30, 10, $formattedRestockLevel, 1, 0, 'C'); // Widened Restock Level column
        $pdf->Cell(40, 10, $formattedDate, 1, 1, 'C');
    }
} else {
    $pdf->Cell(0, 10, 'No materials found', 1, 1, 'C');
}

$pdf->Output('I', 'inventory_report.pdf');
?>
