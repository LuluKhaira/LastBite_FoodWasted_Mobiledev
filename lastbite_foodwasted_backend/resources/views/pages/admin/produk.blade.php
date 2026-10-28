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

    @if (session('success'))
        <div class="rounded-xl bg-green-100 px-4 py-3 text-sm font-bold text-green-700">{{ session('success') }}</div>
    @endif
    @if (session('error'))
        <div class="rounded-xl bg-red-100 px-4 py-3 text-sm font-bold text-red-700">{{ session('error') }}</div>
    @endif

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[900px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Produk</th>
                        <th class="px-4 py-4">Mitra Penjual</th>
                        <th class="px-4 py-4">Harga Asli</th>
                        <th class="px-4 py-4">Harga Diskon</th>
                        <th class="px-4 py-4">Sisa Kuota</th>
                        <th class="px-4 py-4 text-center">Status</th>
                        <th class="px-4 py-4 text-center">Aksi</th>
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
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition {{ $isAnomali ? 'bg-red-50' : '' }} {{ !$produk->aktif ? 'opacity-60' : '' }}">
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
                                <div class="flex flex-col items-center gap-1">
                                    @if($isAnomali)
                                        <span class="inline-flex items-center gap-1 rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-700">
                                            <span class="material-symbols-outlined text-[16px]">warning</span> Anomali
                                        </span>
                                    @endif
                                    @if($produk->aktif)
                                        @if(!$isAnomali)
                                            <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-700">Aktif</span>
                                        @endif
                                    @else
                                        <span class="rounded-full bg-gray-200 px-3 py-1 text-xs font-bold text-gray-600">Nonaktif</span>
                                    @endif
                                </div>
                            </td>
                            <td class="px-4 py-4 text-center">
                                @if($isAnomali || !$produk->aktif)
                                    <form action="{{ route('admin.produk.toggle', $produk->getKey()) }}" method="POST"
                                          onsubmit="return confirm('{{ $produk->aktif ? 'Nonaktifkan' : 'Aktifkan kembali' }} produk {{ addslashes($produk->nama) }}?')">
                                        @csrf
                                        @method('PATCH')
                                        @if($produk->aktif)
                                            <button type="submit" class="inline-flex items-center gap-1 rounded-xl bg-red-600 px-3 py-2 text-xs font-bold text-white hover:bg-red-700 transition">
                                                <span class="material-symbols-outlined text-[16px]">block</span> Nonaktifkan
                                            </button>
                                        @else
                                            <button type="submit" class="inline-flex items-center gap-1 rounded-xl bg-[#2F5D34] px-3 py-2 text-xs font-bold text-white hover:bg-[#235139] transition">
                                                <span class="material-symbols-outlined text-[16px]">check_circle</span> Aktifkan
                                            </button>
                                        @endif
                                    </form>
                                @else
                                    <span class="text-gray-400">-</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="7" class="px-6 py-10 text-center text-[#4E7554]">Belum ada data produk.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection