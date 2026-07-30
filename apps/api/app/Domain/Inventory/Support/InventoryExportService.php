<?php

namespace App\Domain\Inventory\Support;

use App\Domain\Inventory\Models\InventoryItem;
use App\Domain\Inventory\Models\StockMovement;
use App\Models\Farm;
use Carbon\CarbonImmutable;
use Dompdf\Dompdf;
use Dompdf\Options;
use Illuminate\Support\Collection;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Color;
use OpenSpout\Common\Entity\Style\Style;
use OpenSpout\Writer\XLSX\Writer;
use RuntimeException;

final class InventoryExportService
{
    /**
     * @param  Collection<int, InventoryItem>  $items
     * @param  Collection<int, StockMovement>  $movements
     */
    public function pdf(
        Farm $farm,
        string $kind,
        Collection $items,
        Collection $movements,
        ?CarbonImmutable $from,
        ?CarbonImmutable $to,
    ): string {
        $options = new Options;
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', false);

        $dompdf = new Dompdf($options);
        $dompdf->setPaper('A4', 'landscape');
        $dompdf->loadHtml(view('inventory.receipt', [
            'farm' => $farm,
            'kind' => $kind,
            'items' => $items,
            'movements' => $movements,
            'from' => $from?->setTimezone($farm->timezone),
            'to' => $to?->setTimezone($farm->timezone),
            'generatedAt' => now($farm->timezone),
        ])->render(), 'UTF-8');
        $dompdf->render();

        return $dompdf->output();
    }

    /**
     * @param  Collection<int, InventoryItem>  $items
     * @param  Collection<int, StockMovement>  $movements
     */
    public function xlsx(
        Farm $farm,
        string $kind,
        Collection $items,
        Collection $movements,
        ?CarbonImmutable $from,
        ?CarbonImmutable $to,
    ): string {
        $path = tempnam(sys_get_temp_dir(), 'dairycare-inventory-');
        if ($path === false) {
            throw new RuntimeException('A temporary export file could not be created.');
        }

        $writer = new Writer;
        $header = (new Style)
            ->setFontBold()
            ->setFontColor(Color::WHITE)
            ->setBackgroundColor('0E6B57');
        $title = (new Style)
            ->setFontBold()
            ->setFontSize(16)
            ->setFontColor('0E6B57');

        try {
            $writer->openToFile($path);
            $writer->getCurrentSheet()->setName('Inventory summary');
            $writer->addRow(Row::fromValues(['DairyCare inventory export'], $title));
            $writer->addRow(Row::fromValues(['Farm', $farm->name]));
            $writer->addRow(Row::fromValues(['Inventory', ucfirst($kind)]));
            $writer->addRow(Row::fromValues([
                'Movement date range',
                $this->periodLabel($from, $to, $farm->timezone),
            ]));
            $writer->addRow(Row::fromValues(['Generated', now($farm->timezone)->format('Y-m-d H:i:s T')]));
            $writer->addRow(Row::fromValues());
            $writer->addRow(Row::fromValues([
                'Code',
                'Name',
                'Category',
                'Brand',
                'Unit',
                'Current stock',
                'Current value',
                'Batch count',
            ], $header));
            foreach ($items as $item) {
                $writer->addRow(Row::fromValues([
                    $item->item_code,
                    $item->name,
                    $item->category,
                    $item->brand,
                    $item->unit,
                    (float) $item->batches->sum('current_quantity'),
                    (float) $item->batches->sum(
                        fn ($batch): float => (float) $batch->current_quantity * (float) $batch->unit_cost,
                    ),
                    $item->batches->count(),
                ]));
            }

            $writer->addNewSheetAndMakeItCurrent()->setName('Stock movements');
            $writer->addRow(Row::fromValues([
                'Date',
                'Item code',
                'Item',
                'Category',
                'Batch',
                'Movement',
                'Quantity',
                'Unit',
                'Rate',
                'Amount',
                'Supplier',
                'Purchase date',
                'Expiry date',
                'Reason',
            ], $header));
            foreach ($movements as $movement) {
                $writer->addRow(Row::fromValues([
                    $movement->occurred_at?->setTimezone($farm->timezone)->format('Y-m-d H:i:s'),
                    $movement->item?->item_code,
                    $movement->item?->name,
                    $movement->item?->category,
                    $movement->batch?->batch_number,
                    str_replace('_', ' ', ucfirst($movement->movement_type)),
                    (float) $movement->quantity_change,
                    $movement->item?->unit,
                    (float) $movement->unit_cost,
                    (float) $movement->quantity_change * (float) $movement->unit_cost,
                    $movement->batch?->supplier,
                    $movement->batch?->purchase_date?->toDateString(),
                    $movement->batch?->expiry_date?->toDateString(),
                    $movement->reason,
                ]));
            }
            $writer->close();

            $contents = file_get_contents($path);
            if ($contents === false) {
                throw new RuntimeException('The spreadsheet export could not be read.');
            }

            return $contents;
        } finally {
            if (is_file($path)) {
                unlink($path);
            }
        }
    }

    private function periodLabel(
        ?CarbonImmutable $from,
        ?CarbonImmutable $to,
        string $timezone,
    ): string {
        if ($from === null && $to === null) {
            return 'All dates';
        }

        return ($from?->setTimezone($timezone)->toDateString() ?? 'Beginning')
            .' to '
            .($to?->setTimezone($timezone)->toDateString() ?? 'Today');
    }
}
