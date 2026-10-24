@extends('layout.admin')

@section('title', 'Data Pengguna')

@section('content')
<div class="space-y-6">
    <div>
        <h1 class="text-2xl font-extrabold text-[#2F5D34]">Data Pengguna</h1>
        <p class="text-sm text-[#4E7554] mt-1">Daftar pengguna aplikasi LastBite (Pembeli).</p>
    </div>

    <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full min-w-[700px] text-left text-sm">
                <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                    <tr>
                        <th class="px-6 py-4">Nama Pengguna</th>
                        <th class="px-4 py-4">Email</th>
                        <th class="px-4 py-4">No. HP</th>
                        <th class="px-4 py-4">Bergabung</th>
                        <th class="px-4 py-4 text-center">Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                        <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="grid h-10 w-10 place-items-center rounded-full bg-[#A7C957]/40 text-[#2F5D34]">
                                        <span class="material-symbols-outlined">person</span>
                                    </div>
                                    <p class="font-bold text-[#2F5D34]">{{ $user->name }}</p>
                                </div>
                            </td>
                            <td class="px-4 py-4">{{ $user->email ?? '-' }}</td>
                            <td class="px-4 py-4 font-semibold">{{ $user->no_hp ?? '-' }}</td>
                            <td class="px-4 py-4 text-xs text-[#4E7554]">{{ $user->created_at->format('d M Y') }}</td>
                            <td class="px-4 py-4 text-center">
                                @if($user->no_hp_verified_at)
                                    <span class="inline-flex items-center gap-1 text-xs font-bold text-green-600">
                                        <span class="material-symbols-outlined text-[16px]">verified</span> Terverifikasi
                                    </span>
                                @else
                                    <span class="text-xs font-bold text-gray-400">Belum Verifikasi</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="px-6 py-10 text-center text-[#4E7554]">Belum ada data pengguna.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection