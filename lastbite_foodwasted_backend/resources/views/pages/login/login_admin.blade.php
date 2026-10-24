<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link rel="icon" type="image/png" href="{{ asset('images/lastbite_icon.png') }}">
    <title>Masuk Admin - LastBite</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700&family=Poppins:wght@500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,300..400,0,0&display=swap" rel="stylesheet">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        body { font-family: 'Nunito', sans-serif; }
        .font-heading { font-family: 'Poppins', sans-serif; }
        .material-symbols-outlined { font-size: 20px; vertical-align: middle; font-variation-settings: 'wght' 300; }
        .deco { position: absolute; pointer-events: none; user-select: none; z-index: 0; }
        [x-cloak] { display: none !important; }
    </style>
</head>
<body class="min-h-screen bg-white text-[#10260F] antialiased">

<div class="grid min-h-screen lg:grid-cols-2">

    {{-- ============ Panel Kiri ============ --}}
    <aside class="relative hidden lg:flex flex-col justify-between overflow-hidden bg-[#1B352A] p-12 text-[#F8F6F2]">
        
        {{-- Dekorasi Background --}}
        <div class="deco -left-20 -top-20 h-96 w-96 rounded-full bg-[#2F7A4A]/10 blur-3xl"></div>
        <span class="deco -left-10 -top-10 text-white/[0.03] material-symbols-outlined" style="font-size: 280px; transform: rotate(-15deg);">eco</span>
        <span class="deco right-10 top-32 text-white/[0.04] material-symbols-outlined" style="font-size: 140px; transform: rotate(25deg);">eco</span>

        {{-- Konten Utama (Rata Kiri) --}}
        <div class="relative z-10 w-full max-w-[420px] mt-4">
            
            {{-- Logo & Badge --}}
            <div class="mb-10 flex flex-col items-start gap-6">
                <div class="inline-block rounded-2xl bg-[#F8F6F2] p-3 shadow-xl">
                    <img src="{{ asset('images/lastbite_logo.png') }}" alt="LastBite" class="h-16 w-auto">
                </div>
                <div class="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-3 py-1 text-[11px] font-bold tracking-widest uppercase">
                    <span class="h-1.5 w-1.5 rounded-full bg-emerald-400"></span> Platform Operasional
                </div>
            </div>

            {{-- Heading --}}
            <h1 class="font-heading text-[32px] font-bold leading-[1.2] text-[#A7C957] mb-5">
                Selamatkan Makanan,<br>Jaga Masa Depan.
            </h1>
            
            <p class="text-[15px] leading-relaxed text-[#F8F6F2]/70">
                Pusat pemantauan redistribusi surplus pangan, audit kepatuhan higienitas mitra, dan penyaluran bahan bernutrisi untuk ekosistem berkelanjutan.
            </p>
        </div>

        {{-- Konten Bawah (Status & Footer) --}}
        <div class="relative z-10 w-full max-w-[420px] mb-2">
            {{-- Kartu Status --}}
            <div class="rounded-xl border border-white/10 bg-white/[0.04] p-5 backdrop-blur-sm mb-10">
                <div class="flex items-center justify-between border-b border-white/10 pb-3 mb-3">
                    <span class="flex items-center gap-2 text-[13px] font-semibold">
                        <span class="h-2 w-2 rounded-full bg-emerald-400 animate-pulse"></span> Sistem Hub Aktif
                    </span>
                    <span class="text-[10px] font-mono text-white/40 tracking-wider">TLS 1.3 SECURE</span>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-[11px] text-white/50 mb-0.5">Audit Hari Ini</p>
                        <p class="text-[15px] font-bold">3.482 Porsi</p>
                    </div>
                    <div>
                        <p class="text-[11px] text-white/50 mb-0.5">Jejaring Mitra</p>
                        <p class="text-[15px] font-bold">428 Gerai</p>
                    </div>
                </div>
            </div>

            {{-- Ikon & Footer --}}
            <div class="flex items-center justify-between text-white/40">
                <div class="flex gap-4">
                    @foreach (['restaurant', 'shopping_bag', 'potted_plant', 'recycling', 'favorite'] as $icon)
                        <span class="material-symbols-outlined text-lg">{{ $icon }}</span>
                    @endforeach
                </div>
                <span class="text-xs italic">Less Food Waste, More Goodness.</span>
            </div>
        </div>
    </aside>

    {{-- ============ Panel Kanan (Form) ============ --}}
    <main class="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#FAFAFA] px-6 py-12">
        
        {{-- Dekorasi Kanan --}}
        <span class="deco -right-16 -top-16 text-[#A7C957]/10 material-symbols-outlined" style="font-size: 260px; transform: rotate(15deg);">eco</span>

        <div class="relative z-10 w-full max-w-[380px]" x-data="{ show: false }">
            
            {{-- Logo (Hanya muncul di Mobile) --}}
            <div class="mb-10 lg:hidden flex justify-center">
                <img src="{{ asset('images/lastbite_logo.png') }}" alt="LastBite" class="h-16 w-auto">
            </div>

            {{-- Header Form --}}
            <div class="mb-8">
                <p class="text-[11px] font-bold uppercase tracking-widest text-[#1F6B3A] mb-2">Admin Portal</p>
                <h2 class="font-heading text-[28px] font-bold tracking-tight text-[#10260F]">Masuk ke Dashboard</h2>
                <p class="mt-2 text-sm text-[#10260F]/60">Kelola mitra, produk, dan moderasi LastBite.</p>
            </div>

            {{-- Error Alert --}}
            @if ($errors->any())
                <div class="mb-6 flex items-start gap-2 rounded-lg bg-red-50 p-3 text-sm text-red-600 border border-red-100">
                    <span class="material-symbols-outlined text-red-500">error</span>
                    <span class="font-medium pt-0.5">{{ $errors->first() }}</span>
                </div>
            @endif

            {{-- Form --}}
            <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-5">
                @csrf

                {{-- Username --}}
                <div>
                    <label for="username" class="mb-1.5 block text-sm font-semibold text-[#10260F]">Username</label>
                    <div class="relative">
                        <span class="material-symbols-outlined pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-[#10260F]/40">person</span>
                        <input id="username" type="text" name="username" value="{{ old('username') }}" required autofocus autocomplete="username" placeholder="Masukkan username"
                               class="w-full rounded-lg border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm outline-none transition-colors placeholder-[#10260F]/30 focus:border-[#1F6B3A] focus:ring-1 focus:ring-[#1F6B3A]">
                    </div>
                </div>

                {{-- Password --}}
                <div>
                    <label for="password" class="mb-1.5 block text-sm font-semibold text-[#10260F]">Kata Sandi</label>
                    <div class="relative">
                        <span class="material-symbols-outlined pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-[#10260F]/40">lock</span>
                        <input id="password" :type="show ? 'text' : 'password'" name="password" required autocomplete="current-password" placeholder="Masukkan kata sandi"
                               class="w-full rounded-lg border border-gray-200 bg-white py-2.5 pl-10 pr-10 text-sm shadow-sm outline-none transition-colors placeholder-[#10260F]/30 focus:border-[#1F6B3A] focus:ring-1 focus:ring-[#1F6B3A]">
                        <button type="button" @click="show = !show" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#10260F]/40 hover:text-[#10260F] transition-colors" aria-label="Tampilkan kata sandi">
                            <span class="material-symbols-outlined text-lg" x-text="show ? 'visibility_off' : 'visibility'">visibility</span>
                        </button>
                    </div>
                </div>

                {{-- Tombol Submit --}}
                <button type="submit"
                        class="mt-2 flex w-full items-center justify-center gap-2 rounded-lg bg-[#E0885A] py-2.5 text-sm font-bold text-white shadow-sm transition hover:bg-[#d17b4e] focus:outline-none focus:ring-2 focus:ring-[#E0885A]/50 focus:ring-offset-2">
                    Masuk <span class="material-symbols-outlined text-lg">arrow_forward</span>
                </button>
            </form>

            {{-- Footer Kanan --}}
            <div class="mt-16 text-center text-[11px] text-[#10260F]/40">
                &copy; {{ date('Y') }} LastBite &bull; Less Food Waste, More Goodness
            </div>
        </div>
    </main>
</div>

</body>
</html>