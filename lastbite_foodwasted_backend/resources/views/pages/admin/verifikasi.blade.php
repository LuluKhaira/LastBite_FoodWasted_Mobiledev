@extends('layout.admin')

@section('title', 'Verifikasi Mitra')

@section('content')
<div class="space-y-6">
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
                                <a href="{{ route('admin.dashboard', ['mitra' => $mitra->id_mitra]) }}" 
                                   class="inline-flex items-center gap-1 rounded-lg bg-[#2F5D34] px-3 py-1.5 text-xs font-bold text-white hover:bg-[#235139] transition">
                                    <span class="material-symbols-outlined text-[16px]">visibility</span> Tinjau
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="px-6 py-10 text-center text-[#4E7554]">Tidak ada mitra yang menunggu verifikasi.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection