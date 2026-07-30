<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>DairyCare inventory receipt</title>
    <style>
        @page { margin: 28px; }
        body { color: #17211e; font-family: "DejaVu Sans", sans-serif; font-size: 10px; }
        h1 { color: #0e6b57; font-size: 23px; margin: 0 0 4px; }
        h2 { color: #0e6b57; font-size: 15px; margin: 22px 0 7px; }
        .muted { color: #66746f; }
        .meta { border: 1px solid #cbd8d3; border-radius: 5px; margin-top: 12px; padding: 9px; }
        .meta span { display: inline-block; margin-right: 28px; }
        table { border-collapse: collapse; margin-top: 7px; width: 100%; }
        th { background: #0e6b57; color: white; font-weight: bold; padding: 6px; text-align: left; }
        td { border-bottom: 1px solid #dfe7e4; padding: 6px; vertical-align: top; }
        tr:nth-child(even) td { background: #f5f9f7; }
        .number { text-align: right; white-space: nowrap; }
        .empty { background: #f5f9f7; border: 1px solid #dfe7e4; padding: 12px; }
        .footer { color: #66746f; font-size: 8px; margin-top: 18px; }
    </style>
</head>
<body>
    <h1>DairyCare inventory receipt</h1>
    <div class="muted">{{ $farm->name }} · {{ ucfirst($kind) }} inventory</div>
    <div class="meta">
        <span><strong>Generated:</strong> {{ $generatedAt->format('Y-m-d H:i:s T') }}</span>
        <span><strong>Movement period:</strong>
            {{ $from?->toDateString() ?? 'Beginning' }} to {{ $to?->toDateString() ?? 'Today' }}
        </span>
        <span><strong>Items:</strong> {{ $items->count() }}</span>
    </div>

    <h2>Selected inventory</h2>
    <table>
        <thead>
            <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Category</th>
                <th>Unit</th>
                <th class="number">Current stock</th>
                <th class="number">Current value</th>
            </tr>
        </thead>
        <tbody>
        @foreach ($items as $item)
            <tr>
                <td>{{ $item->item_code }}</td>
                <td>{{ $item->name }}</td>
                <td>{{ $item->category }}</td>
                <td>{{ $item->unit }}</td>
                <td class="number">{{ number_format((float) $item->batches->sum('current_quantity'), 3) }}</td>
                <td class="number">{{ number_format((float) $item->batches->sum(fn ($batch) => (float) $batch->current_quantity * (float) $batch->unit_cost), 2) }}</td>
            </tr>
        @endforeach
        </tbody>
    </table>

    <h2>Stock movements in selected period</h2>
    @if ($movements->isEmpty())
        <div class="empty">No stock movements were recorded in this date range.</div>
    @else
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Item</th>
                    <th>Batch</th>
                    <th>Movement</th>
                    <th class="number">Quantity</th>
                    <th class="number">Rate</th>
                    <th class="number">Amount</th>
                    <th>Supplier / reason</th>
                </tr>
            </thead>
            <tbody>
            @foreach ($movements as $movement)
                <tr>
                    <td>{{ $movement->occurred_at?->setTimezone($farm->timezone)->format('Y-m-d H:i') }}</td>
                    <td>{{ $movement->item?->item_code }} · {{ $movement->item?->name }}</td>
                    <td>{{ $movement->batch?->batch_number }}</td>
                    <td>{{ ucfirst(str_replace('_', ' ', $movement->movement_type)) }}</td>
                    <td class="number">{{ number_format((float) $movement->quantity_change, 3) }} {{ $movement->item?->unit }}</td>
                    <td class="number">{{ number_format((float) $movement->unit_cost, 2) }}</td>
                    <td class="number">{{ number_format((float) $movement->quantity_change * (float) $movement->unit_cost, 2) }}</td>
                    <td>{{ $movement->batch?->supplier }}@if($movement->reason) · {{ $movement->reason }}@endif</td>
                </tr>
            @endforeach
            </tbody>
        </table>
    @endif

    <div class="footer">
        This receipt is generated from DairyCare's append-only stock movement ledger. Archived records and historical
        movements are retained for audit integrity.
    </div>
</body>
</html>
