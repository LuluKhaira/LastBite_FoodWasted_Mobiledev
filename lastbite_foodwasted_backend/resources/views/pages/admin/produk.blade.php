@extends('layout.admin')

@section('title', 'Produk & Moderasi')

@section('content')
@php $aturan = \App\Models\AturanHarga::aktif(); @endphp
<div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-[#2F5D34]">Produk & Moderasi</h1>
            <p class="text-sm text-[#4E7554] mt-1">Pantau katalog produk dan tinjau anomali harga.</p>
        </div>
    </div>

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[800px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Produk</th>
                        <th class="px-4 py-4">Mitra Penjual</th>
                        <th class="px-4 py-4">Harga Asli</th>
                        <th class="px-4 py-4">Harga Diskon</th>
                        <th class="px-4 py-4">Sisa Kuota</th>
                        <th class="px-4 py-4 text-center">Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($produks as $produk)
                        @php
                            $pct = $produk->harga_asli > 0 ? (($produk->harga_asli - $produk->harga) / $produk->harga_asli) * 100 : 0;
                            $isAnomali = $produk->harga > $produk->harga_asli                           // jual lebih mahal dari harga asli
                                      || $pct > $aturan->max_diskon                                     // diskon melebihi batas admin
                                      || ($produk->harga > 0 && $produk->harga < $aturan->min_harga);   // di bawah minimum (gratis dikecualikan)
                        @endphp
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition {{ $isAnomali ? 'bg-red-50' : '' }}">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    @if($produk->gambar)
                                        <img src="{{ asset('storage/' . $produk->gambar) }}" alt="{{ $produk->nama }}" class="h-12 w-12 rounded-lg object-cover bg-gray-100">
                                    @else
                                        <div class="h-12 w-12 rounded-lg bg-[#A7C957]/30 flex items-center justify-center"><span class="material-symbols-outlined text-[#2F5D34]">image</span></div>
                                    @endif
                                    <div>
                                        <p class="font-bold text-[#2F5D34]">{{ $produk->nama }}</p>
                                        <p class="text-xs text-[#4E7554]">{{ $produk->kategori }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-4 font-semibold">{{ $produk->mitra->nama_usaha ?? '-' }}</td>
                            <td class="px-4 py-4 text-xs line-through text-gray-500">Rp {{ number_format($produk->harga_asli, 0, ',', '.') }}</td>
                            <td class="px-4 py-4 font-bold text-[#2F5D34]">Rp {{ number_format($produk->harga, 0, ',', '.') }}</td>
                            <td class="px-4 py-4">{{ $produk->kuota }} Porsi</td>
                            <td class="px-4 py-4 text-center">
                                @if($isAnomali)
                                    <span class="inline-flex items-center gap-1 rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-700">
                                        <span class="material-symbols-outlined text-[16px]">warning</span> Anomali
                                    </span>
                                @elseif($produk->aktif)
                                    <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-700">Aktif</span>
                                @else
                                    <span class="rounded-full bg-gray-100 px-3 py-1 text-xs font-bold text-gray-600">Nonaktif</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="6" class="px-6 py-10 text-center text-[#4E7554]">Belum ada data produk.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection