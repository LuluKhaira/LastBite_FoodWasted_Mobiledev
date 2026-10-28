@php
$pendingMitra = \App\Models\Mitra::where(fn ($q) => $q->whereNotIn('status_verifikasi', ['disetujui', 'ditolak'])->orWhereNull('status_verifikasi'))->whereNotNull('foto_ktp')->count();
$menu = [
['Dashboard', 'dashboard', 'admin.dashboard', null],
['Verifikasi Mitra', 'verified_user', 'admin.verifikasi', $pendingMitra ?: null],
['Data Mitra', 'storefront', 'admin.mitra', null],
['Data Pengguna', 'group', 'admin.pengguna', null],
['Produk & Moderasi', 'inventory_2', 'admin.produk', null],
['Pesanan', 'receipt_long', 'admin.pesanan', null],
['Laporan', 'bar_chart', 'admin.laporan', null],
];
$settings = [
['Kategori Produk', 'category', 'admin.kategori'],
['Aturan Harga', 'sell', 'admin.aturan'],
];
@endphp

<aside class="hidden lg:flex fixed inset-y-0 left-0 w-64 flex-col bg-white border-r border-[#A7C957]/30 z-30">
    {{-- Logo --}}
    <div class="flex items-center gap-3 px-6 h-20">
        <img src="{{ asset('images/lastbite_icon.png') }}" alt="LastBite" class="h-11 w-auto">
        <div class="leading-tight">
            <p class="text-lg font-extrabold text-[#2F5D34]">Lastbite</p>
            <p class="text-[11px] font-bold tracking-wider text-[#4E7554]">ADMIN PORTAL</p>
        </div>
    </div>

    {{-- Menu --}}
    <nav class="flex-1 overflow-y-auto px-4 py-2 space-y-1">
        @foreach ($menu as [$label, $icon, $route, $badge])
        @php $active = request()->routeIs($route); @endphp
        <a href="{{ route($route) }}"
            class="flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-semibold transition
                  {{ $active ? 'bg-[#A7C957] text-[#2F5D34]' : 'text-[#2F5D34] hover:bg-[#A7C957]/15' }}">
            <span class="material-symbols-outlined">{{ $icon }}</span>
            <span class="flex-1">{{ $label }}</span>
            @if ($badge)
            <span class="w-5 h-5 rounded-full bg-[#FFB07C] text-[#2F5D34] text-[11px] font-bold grid place-items-center">{{ $badge }}</span>
            @endif
        </a>
        @endforeach

        <p class="px-4 pt-5 pb-1 text-xs font-bold tracking-wider text-[#4E7554]">PENGATURAN</p>
        @foreach ($settings as [$label, $icon, $route])
        @php $active = request()->routeIs($route); @endphp
        <a href="{{ route($route) }}"
            class="flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-semibold transition
                  {{ $active ? 'bg-[#A7C957] text-[#2F5D34]' : 'text-[#2F5D34] hover:bg-[#A7C957]/15' }}">
            <span class="material-symbols-outlined">{{ $icon }}</span>
            <span>{{ $label }}</span>
        </a>
        @endforeach
    </nav>

    {{-- Profil admin --}}
    <div class="m-4 flex items-center gap-3 rounded-2xl bg-[#A7C957]/20 p-3">
        <div class="w-10 h-10 rounded-full bg-[#A7C957] text-[#2F5D34] grid place-items-center text-sm font-bold">AL</div>
        <div class="flex-1 leading-tight">
            <p class="text-sm font-extrabold">Admin Lastbite</p>
            <p class="text-xs font-semibold text-[#2F5D34]">Admin</p>
        </div>
        <form method="POST" action="{{ route('admin.logout') }}">
            @csrf
            <button type="submit" title="Keluar" class="text-[#4E7554] hover:text-red-600">
                <span class="material-symbols-outlined">logout</span>
            </button>
        </form>
    </div>
</aside>