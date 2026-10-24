@extends('layout.admin')

@section('title', 'Laporan')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-[#2F5D34]">Laporan</h1>
            <p class="text-sm text-[#4E7554] mt-1">Rekapitulasi data penyelamatan makanan dan dampak lingkungan.</p>
        </div>
        <button class="inline-flex items-center gap-2 rounded-xl bg-[#2F5D34] px-4 py-2 text-sm font-bold text-white hover:bg-[#235139] transition">
            <span class="material-symbols-outlined">download</span> Ekspor PDF
        </button>
    </div>

    {{-- Ringkasan Card --}}
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="rounded-2xl bg-white p-5 shadow-sm border-l-4 border-[#A7C957]">
            <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]">Total Makanan Diselamatkan</p>
            <p class="mt-2 text-3xl font-extrabold text-[#2F5D34]">{{ number_format($totalMakanan, 2) }} <span class="text-base font-semibold">Kg</span></p>
        </div>
        <div class="rounded-2xl bg-white p-5 shadow-sm border-l-4 border-[#FFB07C]">
            <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]">Total Emisi CO2 Dikurangi</p>
            <p class="mt-2 text-3xl font-extrabold text-[#2F5D34]">{{ number_format($totalCo2, 2) }} <span class="text-base font-semibold">Kg</span></p>
        </div>
        <div class="rounded-2xl bg-white p-5 shadow-sm border-l-4 border-[#2F5D34]">
            <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]">Total Transaksi Selesai</p>
            <p class="mt-2 text-3xl font-extrabold text-[#2F5D34]">{{ number_format($totalTransaksi, 0, ',', '.') }}</p>
        </div>
    </div>

    {{-- Tabel Rekap --}}
    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="p-6 border-b border-[#A7C957]/15">
            <h2 class="text-lg font-extrabold text-[#2F5D34]">Rekap Performa Mitra</h2>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full min-w-[700px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Nama Mitra</th>
                        <th class="px-4 py-4">Pesanan Selesai</th>
                        <th class="px-4 py-4">Makanan (Kg)</th>
                        <th class="px-4 py-4">Pendapatan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($rekapMitra as $rekap)
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2]">
                            <td class="px-6 py-4 font-bold text-[#2F5D34]">{{ $rekap->nama_usaha ?? 'Mitra Tanpa Nama' }}</td>
                            <td class="px-4 py-4">{{ $rekap->total_pesanan }} Transaksi</td>
                            <td class="px-4 py-4">{{ number_format($rekap->total_kg, 2) }} Kg</td>
                            <td class="px-4 py-4 font-bold">Rp {{ number_format($rekap->total_pendapatan, 0, ',', '.') }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="4" class="px-6 py-10 text-center text-[#4E7554]">Belum ada data transaksi.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection