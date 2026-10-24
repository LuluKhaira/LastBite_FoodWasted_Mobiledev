@extends('layout.admin')

@section('title', 'Verifikasi Mitra')

@section('content')
{{-- Inisialisasi Alpine.js untuk state modal --}}
<div class="space-y-6" x-data="{ 
    showModal: false, 
    selectedMitra: null,
    openModal(mitra) {
        this.selectedMitra = mitra;
        this.showModal = true;
        document.body.classList.add('overflow-hidden');
    },
    closeModal() {
        this.showModal = false;
        this.selectedMitra = null;
        document.body.classList.remove('overflow-hidden');
    }
}">

    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-[#2F5D34]">Verifikasi Mitra</h1>
            <p class="text-sm text-[#4E7554] mt-1">Tinjau dan setujui pendaftaran mitra baru LastBite.</p>
        </div>
    </div>

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[800px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Nama Usaha / Mitra</th>
                        <th class="px-4 py-4">Kontak WA</th>
                        <th class="px-4 py-4">Dokumen Legalitas</th>
                        <th class="px-4 py-4">Waktu Pengajuan</th>
                        <th class="px-4 py-4 text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($pendingMitras as $mitra)
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition">
                            <td class="px-6 py-4">
                                <p class="font-extrabold text-[#2F5D34]">{{ $mitra->nama_usaha }}</p>
                                <p class="text-xs text-[#4E7554]">{{ $mitra->alamat ?? 'Alamat belum diisi' }}</p>
                            </td>
                            <td class="px-4 py-4 font-semibold">{{ $mitra->no_whatsapp }}</td>
                            <td class="px-4 py-4">
                                <div class="flex flex-wrap gap-1">
                                    @if($mitra->foto_ktp) <span class="rounded bg-[#A7C957]/30 px-2 py-1 text-[10px] font-bold">KTP</span> @endif
                                    @if($mitra->foto_npwp) <span class="rounded bg-[#A7C957]/30 px-2 py-1 text-[10px] font-bold">NPWP</span> @endif
                                    @if($mitra->sertifikat_halal) <span class="rounded bg-[#A7C957]/30 px-2 py-1 text-[10px] font-bold">Halal</span> @endif
                                </div>
                            </td>
                            <td class="px-4 py-4 text-xs text-[#4E7554]">{{ $mitra->created_at->diffForHumans() }}</td>
                            <td class="px-4 py-4 text-center">
                                {{-- Tombol untuk memicu Modal --}}
                                <button @click="openModal({
                                    id: {{ $mitra->id_mitra }},
                                    nama: '{{ addslashes($mitra->nama_usaha) }}',
                                    alamat: '{{ addslashes($mitra->alamat ?? 'Alamat belum diisi') }}',
                                    wa: '{{ $mitra->no_whatsapp }}',
                                    tanggal: '{{ $mitra->created_at->format('d M Y') }}',
                                    ktp: '{{ $mitra->foto_ktp ? asset('storage/' . $mitra->foto_ktp) : null }}',
                                    npwp: '{{ $mitra->foto_npwp ? asset('storage/' . $mitra->foto_npwp) : null }}',
                                    halal: '{{ $mitra->sertifikat_halal ? asset('storage/' . $mitra->sertifikat_halal) : null }}'
                                })"
                                   class="inline-flex items-center gap-1 rounded-lg bg-[#2F5D34] px-3 py-1.5 text-xs font-bold text-white hover:bg-[#235139] transition">
                                    <span class="material-symbols-outlined text-[16px]">visibility</span> Tinjau
                                </button>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="px-6 py-10 text-center text-[#4E7554]">Tidak ada mitra yang menunggu verifikasi.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- ================= MODAL POPUP DETAIL ================= --}}
    <div x-cloak x-show="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-8" role="dialog" aria-modal="true">
        
        {{-- Backdrop --}}
        <div x-show="showModal" 
             x-transition:enter="transition ease-out duration-300" 
             x-transition:enter-start="opacity-0" 
             x-transition:enter-end="opacity-100" 
             x-transition:leave="transition ease-in duration-200" 
             x-transition:leave-start="opacity-100" 
             x-transition:leave-end="opacity-0" 
             @click="closeModal()" 
             class="absolute inset-0 bg-[#10260F]/60 backdrop-blur-sm"></div>

        {{-- Konten Modal --}}
        <div x-show="showModal" 
             x-transition:enter="transition ease-out duration-300" 
             x-transition:enter-start="opacity-0 translate-y-4 scale-95" 
             x-transition:enter-end="opacity-100 translate-y-0 scale-100" 
             x-transition:leave="transition ease-in duration-200" 
             x-transition:leave-start="opacity-100 translate-y-0 scale-100" 
             x-transition:leave-end="opacity-0 translate-y-4 scale-95" 
             class="relative w-full max-w-3xl max-h-[90vh] flex flex-col overflow-hidden rounded-3xl bg-white shadow-2xl">
            
            {{-- Header Modal --}}
            <div class="flex items-start justify-between border-b border-gray-100 p-6">
                <div class="flex gap-4">
                    <div class="grid h-12 w-12 shrink-0 place-items-center rounded-full bg-[#A7C957]/30 text-[#2F5D34]">
                        <span class="material-symbols-outlined text-2xl">storefront</span>
                    </div>
                    <div>
                        <div class="flex items-center gap-2">
                            <h3 class="text-xl font-extrabold text-[#2F5D34]" x-text="selectedMitra?.nama"></h3>
                            <span class="rounded-full bg-[#A7C957]/20 px-2 py-0.5 text-[10px] font-bold text-[#2F5D34] border border-[#A7C957]/30">Siap Ditinjau</span>
                        </div>
                        <p class="text-sm text-[#4E7554]" x-text="selectedMitra?.alamat"></p>
                    </div>
                </div>
                <button @click="closeModal()" class="text-gray-400 hover:text-gray-600 transition">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            {{-- Body Modal (Scrollable) --}}
            <div class="overflow-y-auto p-6 space-y-6">
                
                {{-- Banner --}}
                <div class="flex items-center gap-2 rounded-xl bg-[#A7C957]/15 p-3 text-sm font-semibold text-[#2F5D34]">
                    <span class="material-symbols-outlined">verified_user</span> Pemeriksaan Berkas Kelayakan & Kepatuhan Pangan LastBite
                </div>

                {{-- Grid Informasi --}}
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 rounded-xl border border-gray-100 p-4 text-sm">
                    <div>
                        <p class="text-xs font-bold text-[#4E7554] mb-1">Kontak WhatsApp</p>
                        <p class="font-semibold" x-text="selectedMitra?.wa"></p>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-[#4E7554] mb-1">Tanggal Pengajuan</p>
                        <p class="font-semibold" x-text="selectedMitra?.tanggal"></p>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-[#4E7554] mb-1">Alamat Fisik</p>
                        <p class="font-semibold" x-text="selectedMitra?.alamat"></p>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-[#4E7554] mb-1">Status Dokumen</p>
                        <p class="font-semibold">Menunggu Verifikasi</p>
                    </div>
                </div>

                {{-- Dokumen & Foto --}}
                <div>
                    <div class="flex items-center justify-between mb-3">
                        <h4 class="text-sm font-extrabold text-[#2F5D34]">Dokumen & Foto Bukti Fisik</h4>
                        <span class="text-xs font-bold text-green-600">Terverifikasi Sistem</span>
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        
                        {{-- Foto KTP --}}
                        <div class="rounded-xl border border-gray-200 overflow-hidden">
                            <template x-if="selectedMitra?.ktp">
                                <img :src="selectedMitra.ktp" class="w-full h-32 object-cover" alt="KTP">
                            </template>
                            <template x-if="!selectedMitra?.ktp">
                                <div class="w-full h-32 bg-gray-50 flex items-center justify-center text-xs text-gray-400">Tidak ada foto KTP</div>
                            </template>
                            <div class="p-2 bg-white border-t border-gray-100 text-center">
                                <p class="text-[11px] font-bold text-[#2F5D34]">KTP Pemilik Usaha</p>
                            </div>
                        </div>

                        {{-- Foto NPWP --}}
                        <div class="rounded-xl border border-gray-200 overflow-hidden">
                            <template x-if="selectedMitra?.npwp">
                                <img :src="selectedMitra.npwp" class="w-full h-32 object-cover" alt="NPWP">
                            </template>
                            <template x-if="!selectedMitra?.npwp">
                                <div class="w-full h-32 bg-gray-50 flex items-center justify-center text-xs text-gray-400">Tidak ada foto NPWP</div>
                            </template>
                            <div class="p-2 bg-white border-t border-gray-100 text-center">
                                <p class="text-[11px] font-bold text-[#2F5D34]">NPWP / Legalitas</p>
                            </div>
                        </div>

                        {{-- Sertifikat Halal --}}
                        <div class="rounded-xl border border-gray-200 overflow-hidden">
                            <template x-if="selectedMitra?.halal">
                                <img :src="selectedMitra.halal" class="w-full h-32 object-cover" alt="Halal">
                            </template>
                            <template x-if="!selectedMitra?.halal">
                                <div class="w-full h-32 bg-gray-50 flex items-center justify-center text-xs text-gray-400">Tidak ada sertifikat</div>
                            </template>
                            <div class="p-2 bg-white border-t border-gray-100 text-center">
                                <p class="text-[11px] font-bold text-[#2F5D34]">Sertifikat Halal</p>
                            </div>
                        </div>

                    </div>
                </div>

                {{-- Form Catatan Admin --}}
                <div>
                    <label class="block text-xs font-bold text-[#4E7554] mb-2">Catatan Auditor Admin</label>
                    <textarea rows="2" class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] p-3 text-sm focus:border-[#A7C957] focus:ring-1 focus:ring-[#A7C957] outline-none" placeholder="Tambahkan catatan audit / instruksi verifikasi untuk merchant ini..."></textarea>
                </div>
            </div>

            {{-- Footer Modal (Aksi) --}}
            <div class="border-t border-gray-100 p-4 bg-[#F8F6F2] flex items-center justify-between gap-3 rounded-b-3xl">
                
                {{-- Tombol Tolak --}}
                <form :action="'/admin/mitra/' + selectedMitra?.id + '/tolak'" method="POST" class="flex-1 flex gap-2">
                    @csrf
                    <input type="text" name="alasan" required placeholder="Pilih Alasan Penolakan..." class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm focus:border-red-400 outline-none">
                    <button type="submit" class="flex items-center gap-1 rounded-xl bg-red-100 px-4 py-2 text-sm font-bold text-red-700 hover:bg-red-200 transition">
                        <span class="material-symbols-outlined text-[18px]">cancel</span> Tolak
                    </button>
                </form>

                {{-- Tombol Setujui --}}
                <form :action="'/admin/mitra/' + selectedMitra?.id + '/setujui'" method="POST" class="shrink-0">
                    @csrf
                    <button type="submit" class="flex items-center gap-1 rounded-xl bg-[#2F5D34] px-6 py-2 text-sm font-bold text-white hover:bg-[#235139] transition">
                        <span class="material-symbols-outlined text-[18px]">check_circle</span> Setujui Mitra Ini
                    </button>
                </form>
            </div>
            
        </div>
    </div>

</div>
@endsection