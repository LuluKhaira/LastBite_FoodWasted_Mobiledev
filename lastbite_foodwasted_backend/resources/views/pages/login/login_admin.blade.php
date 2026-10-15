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
        .deco { position: absolute; pointer-events: none; user-select: none; }
        [x-cloak] { display: none !important; }
    </style>
</head>
<body class="min-h-screen bg-[#F5F6F1] text-[#10260F] antialiased">

<div class="grid min-h-screen lg:grid-cols-[2fr_3fr]">

    {{-- ============ Panel kiri (gelap) ============ --}}
    <aside class="relative hidden lg:flex flex-col justify-between overflow-hidden bg-gradient-to-b from-[#235139] to-[#1B352A] px-12 py-[56px] text-[#F8F6F2]">

        {{-- Dekorasi --}}
        <div class="deco -left-24 -top-24 h-72 w-72 rounded-full bg-[#2F7A4A]/10 blur-2xl"></div>
        <span class="deco material-symbols-outlined -left-10 -top-10 text-[#2F7A4A]/30" style="font-size:230px; transform:rotate(-20deg)">eco</span>
        <span class="deco material-symbols-outlined right-[18%] top-[6%] text-[#3E9A5E]/60" style="font-size:110px; transform:rotate(12deg)">eco</span>
        <span class="deco material-symbols-outlined right-8 top-[27%] text-white/20" style="font-size:26px">bakery_dining</span>
        <span class="deco material-symbols-outlined right-8 top-[31%] text-white/15" style="font-size:22px">nutrition</span>
        <span class="deco material-symbols-outlined right-8 top-[35%] text-white/15" style="font-size:22px">bolt</span>
        <span class="deco material-symbols-outlined bottom-6 right-6 text-white/15" style="font-size:150px; transform:rotate(-15deg)">flatware</span>
        <div class="deco -bottom-16 right-[28%] h-44 w-44 rounded-full border border-white/10"></div>
        <div class="deco bottom-0 left-1/3 h-40 w-40 rounded-full bg-white/5 blur-xl"></div>

        {{-- Atas --}}
        <div class="relative">
            <div class="flex items-center gap-3">
                <span class="rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-xs font-semibold uppercase tracking-wider">Platform Operasional</span>
            </div>

            <div class="mt-6 inline-block rounded-3xl bg-[#F8F6F2] p-5 shadow-lg shadow-black/20">
                <img src="{{ asset('images/lastbite_logo.png') }}" alt="LastBite - Save Food, Save Earth" class="h-48 w-auto">
            </div>
            <p class="mt-5 text-sm font-semibold uppercase tracking-[0.2em] text-[#A7C957]">Selamatkan Makanan, Jaga Masa Depan</p>
            <p class="mt-8 max-w-md text-base leading-relaxed text-[#F8F6F2]/90">
                Pusat pemantauan redistribusi surplus pangan, audit kepatuhan higienitas mitra, dan penyaluran bahan bernutrisi untuk ekosistem berkelanjutan.
            </p>
        </div>

        {{-- Kartu status --}}
        <div class="relative rounded-2xl border border-white/10 bg-white/5 p-5 backdrop-blur-sm">
            <div class="flex items-center justify-between border-b border-white/10 pb-3 text-sm">
                <span class="flex items-center gap-2 font-semibold">
                    <span class="h-2.5 w-2.5 rounded-full bg-emerald-400"></span> Sistem Pengawasan Hub Aktif
                </span>
                <span class="font-mono text-xs text-[#F8F6F2]/60">TLS 1.3 Secure</span>
            </div>
            <div class="mt-3 grid grid-cols-2 gap-4">
                <div>
                    <p class="text-xs text-[#F8F6F2]/60">Audit Hari Ini</p>
                    <p class="mt-1 text-base font-bold text-white">3.482 Porsi Diselamatkan</p>
                </div>
                <div>
                    <p class="text-xs text-[#F8F6F2]/60">Jejaring Mitra</p>
                    <p class="mt-1 text-base font-bold text-white">428 Gerai Terhubung</p>
                </div>
            </div>
        </div>

        {{-- Bawah --}}
        <div class="relative">
            <div class="flex gap-4">
                @foreach (['restaurant', 'shopping_bag', 'potted_plant', 'recycling', 'favorite'] as $icon)
                    <span class="grid h-14 w-14 place-items-center rounded-full border border-white/10 bg-[#1F4733]/80">
                        <span class="material-symbols-outlined">{{ $icon }}</span>
                    </span>
                @endforeach
            </div>
            <p class="mt-6 text-base italic text-[#F8F6F2]/90">Less Food Waste, More Goodness.</p>
        </div>
    </aside>

    {{-- ============ Panel kanan (form) ============ --}}
    <main class="relative flex min-h-screen flex-col overflow-hidden bg-gradient-to-b from-white to-[#F5F6F1] px-6 py-10 sm:px-12 lg:px-[10%]">

        {{-- Dekorasi --}}
        <span class="deco material-symbols-outlined -right-6 -top-6 text-[#A7C957]/25" style="font-size:190px; transform:rotate(25deg)">eco</span>
        <span class="deco material-symbols-outlined right-8 top-[9%] text-[#10260F]/15" style="font-size:24px">flatware</span>
        <span class="deco material-symbols-outlined right-8 top-[15%] text-[#10260F]/12" style="font-size:24px">potted_plant</span>
        <span class="deco material-symbols-outlined bottom-12 right-8 text-[#A7C957]/30" style="font-size:34px">local_florist</span>
        <div class="deco -bottom-16 -left-10 h-40 w-40 rounded-full bg-[#10260F]/5"></div>

        {{-- Form --}}
        <div class="relative flex flex-1 items-center">
            <div class="w-full" x-data="{ show: false }">

                <img src="{{ asset('images/lastbite_logo.png') }}" alt="LastBite" class="mb-6 h-28 w-auto lg:hidden">
                <p class="text-sm font-bold uppercase tracking-widest text-[#1F6B3A]">Admin Portal</p>
                <h2 class="mt-2 font-heading text-5xl font-bold tracking-tight">Masuk ke Dashboard</h2>
                <p class="mt-4 text-base text-[#10260F]/65">Kelola mitra, produk, dan moderasi LastBite.</p>

                @if ($errors->any())
                    <div class="mt-6 flex gap-2 rounded-xl bg-[#F2965F]/20 px-4 py-3 text-sm font-semibold">
                        <span class="material-symbols-outlined">error</span>
                        <span>{{ $errors->first() }}</span>
                    </div>
                @endif

                <form method="POST" action="{{ route('admin.login.submit') }}" class="mt-8 space-y-4">
                    @csrf

                    <div>
                        <label for="username" class="mb-2 block text-sm font-semibold">Username</label>
                        <div class="relative">
                            <span class="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[#10260F]/50">person</span>
                            <input id="username" type="text" name="username" value="{{ old('username') }}" required autofocus autocomplete="username" placeholder="Masukkan username"
                                   class="w-full rounded-xl border border-[#10260F]/10 bg-[#FAFAF7] py-4 pl-12 pr-4 text-base shadow-sm outline-none placeholder-[#10260F]/40 focus:border-[#1F6B3A] focus:ring-2 focus:ring-[#1F6B3A]/20">
                        </div>
                    </div>

                    <div>
                        <label for="password" class="mb-2 block text-sm font-semibold">Kata Sandi</label>
                        <div class="relative">
                            <span class="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[#10260F]/50">lock</span>
                            <input id="password" :type="show ? 'text' : 'password'" name="password" required autocomplete="current-password" placeholder="Masukkan kata sandi"
                                   class="w-full rounded-xl border border-[#10260F]/10 bg-[#FAFAF7] py-4 pl-12 pr-12 text-base shadow-sm outline-none placeholder-[#10260F]/40 focus:border-[#1F6B3A] focus:ring-2 focus:ring-[#1F6B3A]/20">
                            <button type="button" @click="show = !show" class="absolute right-4 top-1/2 -translate-y-1/2 text-[#10260F]/50 hover:text-[#10260F]" aria-label="Tampilkan kata sandi">
                                <span class="material-symbols-outlined" x-text="show ? 'visibility_off' : 'visibility'">visibility</span>
                            </button>
                        </div>
                    </div>

                    <button type="submit"
                            class="mt-2 flex w-full items-center justify-center gap-2 rounded-xl bg-[#E0885A] py-4 text-base font-semibold text-white shadow-sm transition hover:brightness-95 focus:outline-none focus:ring-2 focus:ring-[#E0885A]/50">
                        Masuk <span class="material-symbols-outlined">arrow_forward</span>
                    </button>
                </form>
            </div>
        </div>

        {{-- Footer --}}
        <div class="relative border-t border-[#10260F]/10 pt-4 text-xs text-[#10260F]/45">
            &copy; {{ date('Y') }} LastBite &bull; Less Food Waste, More Goodness
        </div>
    </main>
</div>

</body>
</html>