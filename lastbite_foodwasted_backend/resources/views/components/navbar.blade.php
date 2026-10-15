<header class="sticky top-0 z-20 h-20 flex items-center justify-between gap-4 px-6 bg-white/70 backdrop-blur border-b border-[#A7C957]/30">
    {{-- Pencarian --}}
    <form action="#" method="GET" class="relative w-full max-w-xl">
        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[#4E7554]">search</span>
        <input type="text" name="q" placeholder="Cari mitra, produk, atau ID tiket..."
               class="w-full h-12 pl-12 pr-4 rounded-full bg-[#A7C957]/20 text-sm placeholder-[#4E7554]/70 border-0 focus:ring-2 focus:ring-[#A7C957] outline-none">
    </form>

    {{-- Notifikasi & profil --}}
    <div class="flex items-center gap-4" x-data="{ open: false }">
        <button type="button" class="relative text-[#2F5D34]">
            <span class="material-symbols-outlined">notifications</span>
            <span class="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-red-600"></span>
        </button>
        <span class="h-8 w-px bg-[#A7C957]/40"></span>
        <div class="relative">
            <button type="button" @click="open = !open" class="flex items-center gap-1">
                <span class="w-10 h-10 rounded-full bg-[#A7C957] text-[#2F5D34] grid place-items-center text-sm font-bold">AL</span>
                <span class="material-symbols-outlined">expand_more</span>
            </button>
            <div x-cloak x-show="open" @click.outside="open = false"
                 class="absolute right-0 mt-2 w-44 rounded-2xl bg-white shadow-lg border border-[#A7C957]/30 py-2 text-sm">
                <a href="#" class="block px-4 py-2 hover:bg-[#A7C957]/15">Profil</a>
                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" class="block w-full px-4 py-2 text-left text-red-600 hover:bg-[#A7C957]/15">Keluar</button>
                </form>
            </div>
        </div>
    </div>
</header>