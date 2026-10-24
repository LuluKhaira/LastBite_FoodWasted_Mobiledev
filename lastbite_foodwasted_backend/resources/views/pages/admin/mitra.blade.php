@extends('layout.admin')

@section('title', 'Data Mitra')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-[#2F5D34]">Data Mitra</h1>
            <p class="text-sm text-[#4E7554] mt-1">Daftar seluruh mitra yang terdaftar di platform LastBite.</p>
        </div>
        <form action="" method="GET" class="relative w-full sm:w-64">
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#4E7554]">search</span>
            <input type="text" name="q" value="{{ request('q') }}" placeholder="Cari nama usaha..." 
                   class="w-full rounded-full border-0 bg-white py-2 pl-10 pr-4 text-sm shadow-sm focus:ring-2 focus:ring-[#A7C957]">
        </form>
    </div>

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[800px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Mitra</th>
                        <th class="px-4 py-4">Kontak</th>
                        <th class="px-4 py-4">Status</th>
                        <th class="px-4 py-4">Saldo</th>
                        <th class="px-4 py-4">Bergabung</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($mitras as $mitra)
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#A7C957] font-extrabold text-[#2F5D34]">
                                        {{ substr($mitra->nama_usaha, 0, 2) }}
                                    </div>
                                    <div>
                                        <p class="font-extrabold text-[#2F5D34]">{{ $mitra->nama_usaha }}</p>
                                        <p class="text-xs text-[#4E7554]">{{ $mitra->alamat ?? '-' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-4 font-semibold">{{ $mitra->no_whatsapp }}</td>
                            <td class="px-4 py-4">
                                @if($mitra->status_verifikasi === 'disetujui')
                                    <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-700">Aktif</span>
                                @elseif($mitra->status_verifikasi === 'pending')
                                    <span class="rounded-full bg-yellow-100 px-3 py-1 text-xs font-bold text-yellow-700">Pending</span>
                                @else
                                    <span class="rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-700">Ditolak</span>
                                @endif
                            </td>
                            <td class="px-4 py-4 font-bold text-[#2F5D34]">Rp {{ number_format($mitra->saldo, 0, ',', '.') }}</td>
                            <td class="px-4 py-4 text-xs text-[#4E7554]">{{ $mitra->created_at->format('d M Y') }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="px-6 py-10 text-center text-[#4E7554]">Belum ada data mitra.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-6 py-4 border-t border-[#A7C957]/15">
            {{ $mitras->links() }}
        </div>
    </div>
</div>
@endsection