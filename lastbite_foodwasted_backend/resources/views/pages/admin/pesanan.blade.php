@extends('layout.admin')

@section('title', 'Pesanan')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-[#2F5D34]">Pesanan</h1>
            <p class="text-sm text-[#4E7554] mt-1">Pantau transaksi penyelamatan makanan oleh pengguna.</p>
        </div>
    </div>

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[900px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Kode Pesanan</th>
                        <th class="px-4 py-4">Produk</th>
                        <th class="px-4 py-4">Pembeli</th>
                        <th class="px-4 py-4">Mitra</th>
                        <th class="px-4 py-4">Total</th>
                        <th class="px-4 py-4 text-center">Status Bayar</th>
                        <th class="px-4 py-4 text-center">Status Pesanan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($pesanans as $order)
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition">
                            <td class="px-6 py-4">
                                <p class="font-extrabold text-[#2F5D34]">{{ $order->kode }}</p>
                                <p class="text-xs text-[#4E7554]">{{ $order->created_at->format('d M Y, H:i') }}</p>
                            </td>
                            <td class="px-4 py-4">
                                <p class="font-semibold">{{ $order->produk }}</p>
                                <p class="text-xs text-[#4E7554]">{{ $order->qty }}x @ Rp {{ number_format($order->harga_satuan, 0, ',', '.') }}</p>
                            </td>
                            <td class="px-4 py-4">{{ $order->user->name ?? 'Pelanggan' }}</td>
                            <td class="px-4 py-4">{{ $order->penjual }}</td>
                            <td class="px-4 py-4 font-bold text-[#2F5D34]">Rp {{ number_format($order->total, 0, ',', '.') }}</td>
                            <td class="px-4 py-4 text-center">
                                @if($order->status_bayar === 'lunas')
                                    <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-700">Lunas</span>
                                @elseif($order->status_bayar === 'gagal')
                                    <span class="rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-700">Gagal</span>
                                @else
                                    <span class="rounded-full bg-yellow-100 px-3 py-1 text-xs font-bold text-yellow-700">Belum Bayar</span>
                                @endif
                            </td>
                            <td class="px-4 py-4 text-center">
                                @php
                                    $statusClass = match($order->status) {
                                        'selesai' => 'bg-green-100 text-green-700',
                                        'siap' => 'bg-blue-100 text-blue-700',
                                        'dibatalkan' => 'bg-red-100 text-red-700',
                                        default => 'bg-[#A7C957]/30 text-[#2F5D34]',
                                    };
                                @endphp
                                <span class="rounded-full px-3 py-1 text-xs font-bold uppercase tracking-wider {{ $statusClass }}">
                                    {{ $order->status }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="7" class="px-6 py-10 text-center text-[#4E7554]">Belum ada pesanan masuk.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-6 py-4 border-t border-[#A7C957]/15">
            {{ $pesanans->links() }}
        </div>
    </div>
</div>
@endsection