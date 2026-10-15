@extends('layout.admin')

@section('title', 'Dashboard')

@section('content')
<div class="space-y-6">

    @if (session('status'))
        <div class="flex items-center gap-2 rounded-2xl bg-[#A7C957]/30 px-5 py-3 text-sm font-bold text-[#2F5D34]">
            <span class="material-symbols-outlined">check_circle</span> {{ session('status') }}
        </div>
    @endif

    @if ($errors->any())
        <div class="flex items-center gap-2 rounded-2xl bg-red-100 px-5 py-3 text-sm font-bold text-red-700">
            <span class="material-symbols-outlined">error</span> {{ $errors->first() }}
        </div>
    @endif

    {{-- Statistik --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        @foreach ($stats as $s)
            <x-stat-card :label="$s['label']" :value="$s['value']" :badge="$s['badge']" />
        @endforeach
    </div>

    {{-- State bersama: antrean, tabel, dan panel moderasi (tanpa reload halaman) --}}
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6"
         x-data="{
            filter: 'semua',
            open: false,
            doc: null,
            openDoc(d) { this.doc = d; this.open = true; },
            closeDoc() { this.open = false; },
            tab: '{{ request('tab') === 'anomali' ? 'anomali' : 'mitra' }}',
            selected: @js($selectedId),
            urgent: @js($details->where('urgent', true)->pluck('id')->values()),
            pickMitra(id) {
                this.tab = 'mitra';
                this.selected = id;
                history.replaceState(null, '', '{{ route('admin.dashboard') }}?mitra=' + id);
                this.reveal();
            },
            pickAnomali() {
                this.tab = 'anomali';
                history.replaceState(null, '', '{{ route('admin.dashboard') }}?tab=anomali');
                this.reveal();
            },
            reveal() {
                this.$nextTick(() => {
                    const el = this.$refs.panel;
                    const top = el.getBoundingClientRect().top;
                    if (top < 0 || top > window.innerHeight * 0.6) {
                        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                });
            }
         }">

        {{-- ================= POPUP DOKUMEN ================= --}}
        <div x-cloak x-show="open"
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="transition ease-in duration-200"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             x-effect="document.body.classList.toggle('overflow-hidden', open)"
             @keydown.escape.window="closeDoc()"
             class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-8"
             role="dialog" aria-modal="true">

            {{-- Latar gelap: klik untuk menutup --}}
            <div @click="closeDoc()" class="absolute inset-0 bg-[#2F5D34]/60 backdrop-blur-sm"></div>

            {{-- Kartu popup --}}
            <div :class="open ? 'translate-y-0 scale-100' : 'translate-y-4 scale-95'"
                 class="relative flex max-h-full w-full max-w-3xl transform flex-col overflow-hidden rounded-3xl bg-white shadow-2xl transition duration-300">

                <div class="flex items-center justify-between gap-4 border-b border-[#A7C957]/30 px-6 py-4">
                    <div class="min-w-0 leading-tight">
                        <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]" x-text="doc?.desc"></p>
                        <p class="truncate text-base font-extrabold" x-text="doc?.name"></p>
                    </div>
                    <div class="flex shrink-0 items-center gap-2">
                        <a :href="doc?.url" target="_blank" rel="noopener"
                           class="hidden items-center gap-1 rounded-full bg-[#A7C957]/25 px-4 py-2 text-xs font-bold text-[#2F5D34] transition hover:bg-[#A7C957]/40 sm:flex">
                            <span class="material-symbols-outlined">open_in_new</span> Tab baru
                        </a>
                        <button type="button" @click="closeDoc()" title="Tutup"
                                class="grid h-10 w-10 place-items-center rounded-full bg-[#A7C957]/25 text-[#2F5D34] transition hover:bg-[#A7C957]/40">
                            <span class="material-symbols-outlined">close</span>
                        </button>
                    </div>
                </div>

                <div class="min-h-0 flex-1 overflow-auto bg-[#F8F6F2]">
                    <template x-if="open && doc && doc.pdf">
                        <iframe :src="doc.url" class="h-[70vh] w-full" title="Dokumen"></iframe>
                    </template>
                    <template x-if="open && doc && !doc.pdf">
                        <img :src="doc.url" :alt="doc.name" class="mx-auto max-h-[70vh] w-auto object-contain p-4">
                    </template>
                </div>
            </div>
        </div>

        {{-- ================= KOLOM KIRI ================= --}}
        <div class="xl:col-span-2 space-y-6">

            {{-- Antrean Peninjauan Cepat --}}
            <section class="rounded-3xl bg-white p-6 shadow-sm">
                <div class="flex flex-wrap items-center gap-3">
                    <h2 class="text-xl font-extrabold">Antrean Peninjauan Cepat</h2>
                    @if ($rows->count())
                        <span class="rounded-full bg-[#FFB07C]/35 px-3 py-1 text-xs font-bold text-[#2F5D34]">{{ $rows->count() }} Perlu Tindakan</span>
                    @endif
                </div>

                @if ($queue->isEmpty())
                    <p class="mt-5 rounded-2xl bg-[#A7C957]/20 p-5 text-sm text-[#4E7554]">Belum ada pendaftaran atau produk yang perlu ditinjau.</p>
                @else
                    <div class="mt-5 grid grid-cols-2 lg:grid-cols-4 gap-3">
                        @foreach ($queue as $q)
                            @php
                                $click = $q['type'] === 'mitra' ? "pickMitra({$q['id']})" : 'pickAnomali()';
                                $sel = $q['type'] === 'mitra' ? "selected === {$q['id']}" : 'false';
                            @endphp
                            <a href="{{ $q['url'] }}" @click.prevent="{{ $click }}"
                               :class="{{ $sel }} ? 'border border-transparent bg-[#A7C957]/20' : 'border border-[#A7C957]/30 bg-white'"
                               class="flex min-h-[190px] flex-col justify-between rounded-2xl p-4 transition duration-300 hover:-translate-y-0.5 hover:shadow-md">
                                <div>
                                    <div class="flex items-center justify-between gap-2">
                                        <span class="rounded-md px-2 py-1 text-[11px] font-bold leading-tight
                                            {{ $q['type'] === 'mitra' ? 'bg-[#A7C957]/35 text-[#2F5D34]' : 'bg-red-100 text-red-700' }}">
                                            {{ $q['tag'] }}
                                        </span>
                                        <span class="text-[11px] font-bold {{ $q['urgent'] ? 'text-red-600' : 'text-[#4E7554]' }}">{{ $q['short'] }}</span>
                                    </div>
                                    <p class="mt-3 text-base font-extrabold leading-snug">{{ $q['name'] }}</p>
                                    <p class="mt-1 text-xs text-[#4E7554]">{{ $q['meta'] }}</p>
                                </div>
                                <div class="mt-4 flex items-center justify-between gap-2 text-xs font-bold text-[#4E7554]">
                                    <span>{{ $q['foot'] }}</span>
                                    <span class="material-symbols-outlined {{ $q['type'] === 'mitra' ? 'text-[#2F5D34]' : 'text-red-600' }}">{{ $q['icon'] }}</span>
                                </div>
                            </a>
                        @endforeach
                    </div>
                @endif
            </section>

            {{-- Tabel peninjauan --}}
            <section class="overflow-hidden rounded-3xl bg-white shadow-sm">
                <div class="flex flex-wrap items-center justify-between gap-3 p-6">
                    <div class="flex flex-wrap gap-2">
                        @php
                            $pills = [
                                ['semua', 'Semua', $rows->count()],
                                ['mitra', 'Verifikasi Mitra', $rows->where('type', 'mitra')->count()],
                                ['anomali', 'Anomali Harga', $rows->where('type', 'anomali')->count()],
                            ];
                        @endphp
                        @foreach ($pills as [$key, $label, $count])
                            <button type="button" @click="filter = '{{ $key }}'"
                                    :class="filter === '{{ $key }}' ? 'bg-[#A7C957] text-[#2F5D34]' : 'bg-[#A7C957]/20 text-[#2F5D34]'"
                                    class="rounded-full px-5 py-2 text-sm font-bold transition duration-300">
                                {{ $label }} ({{ $count }})
                            </button>
                        @endforeach
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full min-w-[720px] text-left text-sm">
                        <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                            <tr>
                                <th class="px-6 py-4">Tipe / Status</th>
                                <th class="px-3 py-4">Entitas / Produk</th>
                                <th class="px-3 py-4">Kategori &amp; Wilayah</th>
                                <th class="px-3 py-4">Waktu Unggah</th>
                                <th class="px-3 py-4">Urgensi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($rows as $r)
                                @php
                                    $click = $r['type'] === 'mitra' ? "pickMitra({$r['id']})" : 'pickAnomali()';
                                    $rowSel = $r['type'] === 'mitra' ? "selected === {$r['id']}" : 'false';
                                @endphp
                                <tr x-show="filter === 'semua' || filter === '{{ $r['type'] }}'"
                                    x-transition.opacity.duration.300ms
                                    :class="{{ $rowSel }} ? 'bg-[#A7C957]/15' : '{{ $r['urgent'] ? 'bg-red-50' : '' }}'"
                                    class="border-t border-[#A7C957]/15 transition-colors duration-300">
                                    <td class="px-6 py-5">
                                        <span class="inline-block rounded-md px-2 py-1 text-xs font-bold
                                            {{ $r['type'] === 'mitra' ? 'bg-[#A7C957]/35 text-[#2F5D34]' : 'bg-red-100 text-red-700' }}">
                                            {{ $r['type'] === 'mitra' ? 'Pendaftaran Mitra' : 'Harga Tidak Wajar' }}
                                        </span>
                                    </td>
                                    <td class="px-3 py-5">
                                        <a href="{{ $r['url'] }}" @click.prevent="{{ $click }}" class="font-extrabold hover:underline">{{ $r['name'] }}</a>
                                        <p class="text-xs text-[#4E7554]">{{ $r['sub'] }}</p>
                                    </td>
                                    <td class="px-3 py-5">
                                        <p class="font-semibold">{{ $r['kategori'] }}</p>
                                        <p class="text-xs text-[#4E7554]">{{ $r['wilayah'] }}</p>
                                    </td>
                                    <td class="px-3 py-5 text-xs text-[#4E7554]">{{ $r['waktu'] }}</td>
                                    <td class="px-3 py-5 text-xs font-bold {{ $r['urgent'] ? 'text-red-600' : 'text-[#4E7554]' }}">
                                        @if ($r['urgent'])<span class="mr-1 inline-block h-2 w-2 rounded-full bg-red-600"></span>@endif
                                        {{ $r['urgensi'] }}
                                    </td>
                                </tr>
                            @empty
                                <tr><td colspan="5" class="px-6 py-10 text-center text-[#4E7554]">Tidak ada peninjauan aktif.</td></tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="px-6 py-4 text-sm text-[#4E7554]">
                    Menampilkan {{ $rows->count() }} dari {{ $rows->count() }} peninjauan aktif
                </div>
            </section>
        </div>

        {{-- ================= KOLOM KANAN ================= --}}
        <div class="space-y-6">

            {{-- Panel Moderasi --}}
            <section id="panel-moderasi" x-ref="panel" class="scroll-mt-24 rounded-3xl bg-white p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]">Panel Moderasi</p>
                    <span x-cloak x-show="tab === 'mitra' && urgent.includes(selected)" x-transition.opacity.duration.300ms
                          class="rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-700">Mendesak (&gt;2 hari)</span>
                </div>
                <h2 class="mt-2 text-2xl font-extrabold">Detail Peninjauan</h2>

                <div class="mt-4 grid grid-cols-2 gap-1 rounded-2xl bg-[#A7C957]/20 p-1 text-sm font-bold">
                    <button type="button" @click="tab = 'mitra'"
                            :class="tab === 'mitra' ? 'bg-white text-[#2F5D34] shadow-sm' : 'text-[#4E7554]'"
                            class="rounded-xl py-2 transition duration-300">Mitra Terpilih</button>
                    <button type="button" @click="tab = 'anomali'"
                            :class="tab === 'anomali' ? 'bg-white text-[#2F5D34] shadow-sm' : 'text-[#4E7554]'"
                            class="rounded-xl py-2 transition duration-300">Anomali Produk ({{ $anomalies->count() }})</button>
                </div>

                {{-- Tab: Mitra --}}
                <div x-show="tab === 'mitra'" class="mt-5"
                     x-transition:enter="transition ease-out duration-300"
                     x-transition:enter-start="opacity-0"
                     x-transition:enter-end="opacity-100">

                    {{-- Kosong: belum ada yang dipilih --}}
                    <div x-cloak x-show="selected === null"
                         x-transition:enter="transition ease-out duration-300"
                         x-transition:enter-start="opacity-0 translate-y-2"
                         x-transition:enter-end="opacity-100 translate-y-0"
                         class="rounded-2xl bg-[#A7C957]/20 p-6 text-center text-sm text-[#4E7554]">
                        <span class="material-symbols-outlined mb-2 block text-[#2F5D34]" style="font-size:36px">fact_check</span>
                        @if ($details->count())
                            Pilih mitra dari antrean atau tabel untuk melihat detail peninjauan.
                        @else
                            Belum ada pendaftaran mitra yang menunggu verifikasi.
                        @endif
                    </div>

                    {{-- Satu blok per mitra; yang dipilih ditampilkan dengan animasi --}}
                    @foreach ($details as $d)
                        <div x-cloak x-show="selected === {{ $d['id'] }}"
                             x-transition:enter="transition ease-out duration-300"
                             x-transition:enter-start="opacity-0 translate-y-3"
                             x-transition:enter-end="opacity-100 translate-y-0"
                             class="space-y-4">

                            <div class="flex items-center gap-4 rounded-2xl bg-[#A7C957]/20 p-4">
                                <div class="grid h-14 w-14 shrink-0 place-items-center rounded-xl bg-[#A7C957] text-xl font-extrabold text-[#2F5D34]">{{ $d['initial'] }}</div>
                                <div class="leading-snug">
                                    <p class="text-lg font-extrabold">{{ $d['name'] }}</p>
                                    <p class="text-xs text-[#4E7554]">{{ $d['kategori'] }}</p>
                                    <p class="text-xs font-bold text-[#2F5D34]">{{ $d['code'] }}</p>
                                </div>
                            </div>

                            <dl class="space-y-3 text-sm">
                                <div><dt class="text-xs font-bold text-[#2F5D34]">Kontak WhatsApp</dt><dd class="text-base font-bold">{{ $d['wa'] }}</dd></div>
                                <div><dt class="text-xs font-bold text-[#2F5D34]">Alamat Fisik Outlet</dt><dd class="text-base">{{ $d['alamat'] }}</dd></div>
                                <div><dt class="text-xs font-bold text-[#2F5D34]">Waktu Pengajuan</dt><dd class="text-base">{{ $d['waktu'] }}</dd></div>
                            </dl>

                            <div>
                                <p class="mb-2 text-xs font-bold uppercase tracking-wide">Dokumen Verifikasi ({{ count($d['docs']) }})</p>
                                <div class="space-y-2">
                                    @foreach ($d['docs'] as $doc)
                                        <div class="flex items-center gap-3 rounded-xl bg-[#A7C957]/20 px-4 py-3">
                                            <span class="material-symbols-outlined text-[#2F5D34]">{{ $doc['icon'] }}</span>
                                            <div class="min-w-0 flex-1 leading-tight">
                                                <p class="truncate text-sm font-bold">{{ $doc['name'] }}</p>
                                                <p class="text-xs font-semibold text-[#4E7554]">{{ $doc['desc'] }}</p>
                                            </div>
                                            @php
                                                $docData = [
                                                    'url' => $doc['url'],
                                                    'name' => $doc['name'],
                                                    'desc' => $doc['desc'],
                                                    'pdf' => str_ends_with(strtolower($doc['name']), '.pdf'),
                                                ];
                                            @endphp
                                            <button type="button" @click="openDoc(@js($docData))" title="Lihat dokumen"
                                                    class="text-[#4E7554] transition hover:text-[#2F5D34]">
                                                <span class="material-symbols-outlined">visibility</span>
                                            </button>
                                        </div>
                                    @endforeach
                                </div>
                            </div>

                            <div class="flex gap-2 rounded-xl bg-[#A7C957]/20 p-4 text-sm text-[#4E7554]">
                                <span class="material-symbols-outlined text-[#2F5D34]">info</span>
                                <p><b class="text-[#2F5D34]">Catatan Akses Admin:</b> Admin hanya berwenang memeriksa validitas data legalitas &amp; pendaftaran, bukan data transaksi internal perbankan mitra.</p>
                            </div>

                            <form method="POST" action="{{ route('admin.mitra.setujui', $d['id']) }}">
                                @csrf
                                <button type="submit"
                                        class="flex w-full items-center justify-center gap-2 rounded-2xl bg-[#A7C957] py-3.5 text-base font-extrabold text-[#2F5D34] transition hover:brightness-95">
                                    <span class="material-symbols-outlined">check_circle</span> Setujui Pendaftaran Mitra
                                </button>
                            </form>

                            <form method="POST" action="{{ route('admin.mitra.tolak', $d['id']) }}" class="space-y-3">
                                @csrf
                                <input type="text" name="alasan" required maxlength="255"
                                       placeholder="Alasan penolakan jika ditolak (cth. Dokumen NIB buram)..."
                                       class="w-full rounded-xl border-0 bg-[#A7C957]/20 px-4 py-3 text-sm placeholder-[#4E7554]/60 focus:ring-2 focus:ring-[#A7C957]">
                                <button type="submit"
                                        class="flex w-full items-center justify-center gap-2 rounded-2xl bg-red-100 py-3 text-sm font-extrabold text-red-700 transition hover:bg-red-200">
                                    <span class="material-symbols-outlined">cancel</span> Tolak Pendaftaran
                                </button>
                            </form>
                        </div>
                    @endforeach
                </div>

                {{-- Tab: Anomali --}}
                <div x-cloak x-show="tab === 'anomali'" class="mt-5 space-y-2"
                     x-transition:enter="transition ease-out duration-300"
                     x-transition:enter-start="opacity-0 translate-y-2"
                     x-transition:enter-end="opacity-100 translate-y-0">
                    @forelse ($anomalies as $a)
                        <div class="rounded-xl bg-[#A7C957]/20 px-4 py-3">
                            <p class="text-sm font-extrabold">{{ $a->nama_produk }}</p>
                            <p class="text-xs text-[#4E7554]">{{ $a->nama_usaha ?? 'Mitra' }}</p>
                            <p class="mt-1 text-xs font-bold text-red-600">
                                Rp {{ number_format($a->harga_asli, 0, ',', '.') }} &rarr; Rp {{ number_format($a->harga_diskon, 0, ',', '.') }}
                                (diskon {{ $a->pct }}%)
                            </p>
                        </div>
                    @empty
                        <p class="rounded-2xl bg-[#A7C957]/20 p-5 text-sm text-[#4E7554]">Tidak ada produk dengan harga di luar aturan.</p>
                    @endforelse
                </div>
            </section>

            {{-- Aktivitas Moderasi Terkini --}}
            <section class="rounded-3xl bg-white p-6 shadow-sm">
                <h3 class="text-sm font-extrabold">Aktivitas Moderasi Terkini</h3>
                <ul class="mt-3 space-y-2 text-sm">
                    @forelse ($activities as $a)
                        <li class="flex items-center justify-between gap-3">
                            <span>{{ $a['text'] }}</span>
                            <span class="whitespace-nowrap text-xs font-semibold text-[#4E7554]">{{ $a['time'] }}</span>
                        </li>
                    @empty
                        <li class="text-[#4E7554]">Belum ada aktivitas.</li>
                    @endforelse
                </ul>
            </section>
        </div>
    </div>
</div>
@endsection