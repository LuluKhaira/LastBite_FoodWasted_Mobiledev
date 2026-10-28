@extends('layout.admin')

@section('title', 'Kategori Produk')

@section('content')
@php
    $grup = [
        'dimakan' => ['Kategori makanan', 'Dijual untuk dikonsumsi manusia. Saat kadaluarsa, produk dialihkan ke kategori tujuan.'],
        'pakan'   => ['Tujuan pengalihan: pakan', 'Kategori untuk pakan ternak dan ikan.'],
        'kompos'  => ['Tujuan pengalihan: kompos', 'Kategori untuk bahan kompos, pupuk, dan limbah organik.'],
    ];
@endphp
<div class="space-y-6"
     x-data="{
        edit: null,
        openEdit(k) { this.edit = k; document.body.classList.add('overflow-hidden'); },
        closeEdit() { this.edit = null; document.body.classList.remove('overflow-hidden'); }
     }">

    <div>
        <h1 class="text-2xl font-extrabold text-[#2F5D34]">Kategori Produk</h1>
        <p class="text-sm text-[#4E7554] mt-1">Atur kategori yang tampil di aplikasi dan tujuan pengalihan saat produk kadaluarsa.</p>
    </div>

    @if (session('success'))
        <div class="rounded-xl bg-green-100 px-4 py-3 text-sm font-bold text-green-700">{{ session('success') }}</div>
    @endif
    @if ($errors->any())
        <div class="rounded-xl bg-red-100 px-4 py-3 text-sm font-bold text-red-700">{{ $errors->first() }}</div>
    @endif

    {{-- Tambah kategori --}}
    <div class="rounded-3xl bg-white p-6 shadow-sm" x-data="{ tipe: '{{ old('tipe', 'dimakan') }}' }">
        <h2 class="text-lg font-extrabold text-[#2F5D34] mb-4">Tambah kategori</h2>
        <form action="{{ route('admin.kategori.simpan') }}" method="POST" class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
            @csrf
            <div class="md:col-span-1">
                <label class="block text-xs font-bold text-[#4E7554] mb-1">Nama kategori</label>
                <input type="text" name="nama" value="{{ old('nama') }}" required maxlength="100"
                       class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
            </div>
            <div>
                <label class="block text-xs font-bold text-[#4E7554] mb-1">Tipe</label>
                <select name="tipe" x-model="tipe"
                        class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                    <option value="dimakan">Makanan (dimakan)</option>
                    <option value="pakan">Pakan</option>
                    <option value="kompos">Kompos</option>
                </select>
            </div>
            <div x-show="tipe === 'dimakan'">
                <label class="block text-xs font-bold text-[#4E7554] mb-1">Dialihkan ke</label>
                <select name="tujuan_id"
                        class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                    <option value="">Default (Pakan Ternak &amp; Ikan)</option>
                    @foreach ($opsiTujuan as $t)
                        <option value="{{ $t->id }}">{{ $t->nama }}</option>
                    @endforeach
                </select>
            </div>
            <div>
                <button type="submit" class="flex w-full items-center justify-center gap-2 rounded-xl bg-[#2F5D34] px-5 py-2.5 text-sm font-bold text-white hover:bg-[#235139] transition">
                    <span class="material-symbols-outlined">add</span> Tambah
                </button>
            </div>
        </form>
    </div>

    {{-- Daftar per tipe --}}
    @foreach ($grup as $tipe => [$judul, $ket])
        @php $baris = $kategoris->where('tipe', $tipe); @endphp
        <div class="rounded-3xl bg-white shadow-sm overflow-hidden">
            <div class="p-6 border-b border-[#A7C957]/15">
                <h2 class="text-lg font-extrabold text-[#2F5D34]">{{ $judul }}</h2>
                <p class="text-xs text-[#4E7554] mt-1">{{ $ket }}</p>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full min-w-[700px] text-left text-sm">
                    <thead class="bg-[#A7C957]/20 text-xs font-bold uppercase tracking-wide text-[#4E7554]">
                        <tr>
                            <th class="px-6 py-4">Nama</th>
                            @if ($tipe === 'dimakan')
                                <th class="px-4 py-4">Dialihkan ke</th>
                            @endif
                            <th class="px-4 py-4">Produk</th>
                            <th class="px-4 py-4">Urutan</th>
                            <th class="px-4 py-4 text-center">Status</th>
                            <th class="px-4 py-4 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($baris as $k)
                            <tr class="border-t border-[#A7C957]/15 hover:bg-[#F8F6F2] transition {{ $k->aktif ? '' : 'opacity-60' }}">
                                <td class="px-6 py-4 font-bold text-[#2F5D34]">{{ $k->nama }}</td>
                                @if ($tipe === 'dimakan')
                                    <td class="px-4 py-4">{{ $k->tujuan?->nama ?? 'Default' }}</td>
                                @endif
                                <td class="px-4 py-4">{{ $jumlahProduk[$k->nama] ?? 0 }}</td>
                                <td class="px-4 py-4">{{ $k->urutan }}</td>
                                <td class="px-4 py-4 text-center">
                                    @if ($k->aktif)
                                        <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-700">Aktif</span>
                                    @else
                                        <span class="rounded-full bg-gray-100 px-3 py-1 text-xs font-bold text-gray-600">Nonaktif</span>
                                    @endif
                                </td>
                                <td class="px-4 py-4">
                                    <div class="flex items-center justify-center gap-2">
                                        <button type="button"
                                                @click="openEdit(@js(['id' => $k->id, 'nama' => $k->nama, 'tipe' => $k->tipe, 'urutan' => $k->urutan, 'tujuan_id' => (string) ($k->tujuan_id ?? ''), 'produk' => $jumlahProduk[$k->nama] ?? 0]))"
                                                class="inline-flex items-center gap-1 rounded-lg bg-[#A7C957]/30 px-3 py-1.5 text-xs font-bold text-[#2F5D34] hover:bg-[#A7C957]/50 transition">
                                            <span class="material-symbols-outlined text-[16px]">edit</span> Ubah
                                        </button>
                                        <form action="{{ route('admin.kategori.toggle', $k->id) }}" method="POST">
                                            @csrf
                                            <button type="submit"
                                                    class="inline-flex items-center gap-1 rounded-lg px-3 py-1.5 text-xs font-bold transition {{ $k->aktif ? 'bg-red-100 text-red-700 hover:bg-red-200' : 'bg-green-100 text-green-700 hover:bg-green-200' }}">
                                                {{ $k->aktif ? 'Nonaktifkan' : 'Aktifkan' }}
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr><td colspan="6" class="px-6 py-8 text-center text-[#4E7554]">Belum ada kategori.</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    @endforeach

    {{-- Modal ubah --}}
    <div x-cloak x-show="edit" class="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
        <div @click="closeEdit()" class="absolute inset-0 bg-[#10260F]/60 backdrop-blur-sm"></div>
        <div class="relative w-full max-w-md rounded-3xl bg-white p-6 shadow-2xl">
            <div class="flex items-start justify-between mb-4">
                <h3 class="text-lg font-extrabold text-[#2F5D34]">Ubah kategori</h3>
                <button type="button" @click="closeEdit()" class="text-gray-400 hover:text-gray-600"><span class="material-symbols-outlined">close</span></button>
            </div>
            <form :action="'/admin/kategori/' + (edit ? edit.id : '')" method="POST" class="space-y-4">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-xs font-bold text-[#4E7554] mb-1">Nama kategori</label>
                    <input type="text" name="nama" required maxlength="100" :value="edit ? edit.nama : ''"
                           class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                    <p class="mt-1 text-xs text-[#4E7554]" x-show="edit && edit.produk > 0">
                        Mengubah nama ikut memperbarui <b x-text="edit ? edit.produk : 0"></b> produk yang memakai kategori ini.
                    </p>
                </div>
                <div>
                    <label class="block text-xs font-bold text-[#4E7554] mb-1">Urutan tampil</label>
                    <input type="number" name="urutan" min="0" max="999" :value="edit ? edit.urutan : 0"
                           class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                </div>
                <div x-show="edit && edit.tipe === 'dimakan'">
                    <label class="block text-xs font-bold text-[#4E7554] mb-1">Dialihkan ke saat kadaluarsa</label>
                    <select name="tujuan_id" x-model="edit.tujuan_id"
                            class="w-full rounded-xl border border-gray-200 bg-[#F8F6F2] px-3 py-2.5 text-sm font-semibold focus:border-[#A7C957] focus:ring-2 focus:ring-[#A7C957]/20">
                        <option value="">Default (Pakan Ternak &amp; Ikan)</option>
                        @foreach ($opsiTujuan as $t)
                            <option value="{{ $t->id }}">{{ $t->nama }}</option>
                        @endforeach
                    </select>
                </div>
                <p class="text-xs text-[#4E7554]">Tipe kategori tidak bisa diubah setelah dibuat, supaya produk lama tetap konsisten.</p>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" @click="closeEdit()" class="rounded-xl bg-gray-100 px-4 py-2 text-sm font-bold text-gray-700 hover:bg-gray-200">Batal</button>
                    <button type="submit" class="rounded-xl bg-[#2F5D34] px-5 py-2 text-sm font-bold text-white hover:bg-[#235139]">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection