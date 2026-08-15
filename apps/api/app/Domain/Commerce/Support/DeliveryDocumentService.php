<?php

namespace App\Domain\Commerce\Support;

use Dompdf\Dompdf;
use Dompdf\Options;
use App\Models\Farm;
use App\Models\User;
use Illuminate\Support\Collection;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Color;
use OpenSpout\Common\Entity\Style\Style;
use OpenSpout\Writer\XLSX\Writer;
use RuntimeException;

final class DeliveryDocumentService
{
    public function pdf(string $view, array $data): string
    {
        $options = new Options();
        $options->set('isRemoteEnabled', false);
        $pdf = new Dompdf($options);
        $pdf->setPaper('A4');
        $pdf->loadHtml(view($view, $data)->render());
        $pdf->render();
        return $pdf->output();
    }

    public function xlsx(Farm $farm, ?User $owner, Collection $manifests, ?string $from, ?string $to, ?string $status): string
    {
        $path = tempnam(sys_get_temp_dir(), 'dairycare-deliveries-');
        if ($path === false) throw new RuntimeException('A temporary export file could not be created.');
        $writer = new Writer;
        $header = (new Style)->setFontBold()->setFontColor(Color::WHITE)->setBackgroundColor('0E6B57');
        try {
            $writer->openToFile($path);
            $writer->getCurrentSheet()->setName('Delivery summary');
            $writer->addRow(Row::fromValues(['DairyCare delivery history'], (new Style)->setFontBold()->setFontSize(16)->setFontColor('0E6B57')));
            foreach ([['Farm', $farm->name], ['Owner', $owner?->name ?? 'Not provided'], ['Phone', $owner?->phone_number ?? 'Not provided'], ['Date range', ($from ?? 'Beginning').' to '.($to ?? 'Today')], ['Status', $status ?? 'All'], ['Generated', now($farm->timezone)->format('Y-m-d H:i:s T')]] as $row) $writer->addRow(Row::fromValues($row));
            $writer->addRow(Row::fromValues());
            $writer->addRow(Row::fromValues(['Delivery', 'Date', 'Route', 'Vehicle', 'Driver', 'Status', 'Planned L', 'Loaded L', 'Delivered L', 'Returned L', 'Rejected L'], $header));
            foreach ($manifests as $m) $writer->addRow(Row::fromValues([$m->delivery_number, $m->delivery_date->toDateString(), $m->route->name, $m->vehicle->registration_number, $m->driver->name, $m->status, (float)$m->planned_quantity, (float)$m->loaded_quantity, (float)$m->delivered_quantity, (float)$m->returned_quantity, (float)$m->rejected_quantity]));
            $writer->addNewSheetAndMakeItCurrent()->setName('Customer stops');
            $writer->addRow(Row::fromValues(['Delivery', 'Order', 'Customer', 'Invoice', 'Status', 'Planned L', 'Delivered L', 'Returned L', 'Rejected L', 'Delivered at', 'Acknowledged by', 'GPS latitude', 'GPS longitude', 'Proof saved'], $header));
            foreach ($manifests as $m) foreach ($m->stops as $s) $writer->addRow(Row::fromValues([$m->delivery_number, $s->stop_order, $s->customer->name, $s->sale->invoice_number, $s->status, (float)$s->planned_quantity, (float)$s->delivered_quantity, (float)$s->returned_quantity, (float)$s->rejected_quantity, $s->delivered_at?->setTimezone($farm->timezone)->format('Y-m-d H:i:s'), $s->acknowledged_by, $s->gps_latitude, $s->gps_longitude, $s->proof_storage_path ? 'Yes' : 'No']));
            $writer->addNewSheetAndMakeItCurrent()->setName('Milk returns');
            $writer->addRow(Row::fromValues(['Return', 'Delivery', 'Invoice', 'Customer', 'Returned L', 'Rejected L', 'Restocked L', 'Disposed L', 'Credit PKR', 'Refund due PKR', 'Refunded PKR', 'Refund status', 'Reason'], $header));
            foreach ($manifests as $m) foreach ($m->stops as $s) if ($s->saleReturn) $writer->addRow(Row::fromValues([$s->saleReturn->return_number, $m->delivery_number, $s->sale->invoice_number, $s->customer->name, (float)$s->saleReturn->returned_quantity, (float)$s->saleReturn->rejected_quantity, (float)$s->saleReturn->restocked_quantity, (float)$s->saleReturn->disposed_quantity, (float)$s->saleReturn->credit_amount, (float)$s->saleReturn->refund_due, (float)$s->saleReturn->refunded_amount, $s->saleReturn->refund_status, $s->saleReturn->reason]));
            $writer->addNewSheetAndMakeItCurrent()->setName('Customer refunds');
            $writer->addRow(Row::fromValues(['Refund', 'Date', 'Customer', 'Invoice', 'Return', 'Amount PKR', 'Method', 'Reference', 'Notes'], $header));
            foreach ($manifests as $m) foreach ($m->stops as $s) foreach ($s->saleReturn?->refunds ?? [] as $r) $writer->addRow(Row::fromValues([$r->refund_number, $r->refund_date->toDateString(), $s->customer->name, $s->sale->invoice_number, $s->saleReturn->return_number, (float)$r->amount, $r->payment_method, $r->reference, $r->notes]));
            $writer->close();
            $contents = file_get_contents($path);
            if ($contents === false) throw new RuntimeException('The spreadsheet export could not be read.');
            return $contents;
        } finally { if (is_file($path)) unlink($path); }
    }
}
