@extends('layout.admin')

@section('title', 'Aturan Harga')

@section('content')
<div class="space-y-6 max-w-3xl">
    <div>
        <h1 class="text-2xl font-extrabold text-[#2F5D34]">Aturan Harga</h1>
        <p class="text-sm text-[#4E7554] mt-1">Konfigurasi batasan harga untuk mencegah anomali pada produk mitra.</p>
    </div>

    <div class="rounded-3xl bg-white p-6 sm:p-8 shadow-sm">
        <form action="#" method="POST" class="space-y-6">
            @csrf
            {{-- Batas Diskon --}}
            <div>
                <label class="block text-sm font-bold text-[#2F5D34] mb-2">Batas Maksimal Diskon (%)</label>
                <div class="relative">
                    <input type="number" name="max_diskon" value="{{ $aturan->max_diskon ?? 90 }}" min="1" max="99"
                           class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] py-3 pl-4 pr-12 text-sm font-bold text-[#2F5D34] focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                    <span class="absolute right-4 top-1/2 -translate-y-1/2 font-bold text-[#4E7554]">%</span>
                </div>
                <p class="mt-2 text-xs text-[#4E7554]">Produk dengan diskon di atas batas ini akan ditandai sebagai <b class="text-red-500">Anomali Harga</b> di dashboard.</p>
            </div>

            {{-- Batas Minimal Harga --}}
            <div>
                <label class="block text-sm font-bold text-[#2F5D34] mb-2">Batas Minimal Harga Jual (Rp)</label>
                <div class="relative">
                    <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-[#4E7554]">Rp</span>
                    <input type="number" name="min_harga" value="{{ $aturan->min_harga ?? 1000 }}" min="0" step="500"
                           class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] py-3 pl-12 pr-4 text-sm font-bold text-[#2F5D34] focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                </div>
                <p class="mt-2 text-xs text-[#4E7554]">Mitra tidak dapat menjual produk di bawah harga ini (kecuali gratis/0).</p>
            </div>

            {{-- Biaya Layanan --}}
            <div>
                <label class="block text-sm font-bold text-[#2F5D34] mb-2">Biaya Layanan Platform (Rp)</label>
                <div class="relative">
                    <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-[#4E7554]">Rp</span>
                    <input type="number" name="biaya_layanan" value="{{ $aturan->biaya_layanan ?? 2000 }}" min="0" step="500"
                           class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] py-3 pl-12 pr-4 text-sm font-bold text-[#2F5D34] focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                </div>
            </div>

            <div class="pt-4 border-t border-[#A7C957]/30">
                <button type="submit" class="flex w-full sm:w-auto items-center justify-center gap-2 rounded-xl bg-[#2F5D34] px-6 py-3 text-sm font-bold text-white shadow-sm hover:bg-[#235139] transition">
                    <span class="material-symbols-outlined">save</span> Simpan Pengaturan
                </button>
            </div>
        </form>
    </div>
</div>
@endsection