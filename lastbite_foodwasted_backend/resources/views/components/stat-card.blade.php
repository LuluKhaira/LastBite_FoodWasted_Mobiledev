@props(['label', 'value', 'badge' => null])

<div class="rounded-2xl bg-white p-5 shadow-sm">
    <p class="text-xs font-bold uppercase tracking-wide text-[#4E7554]">{{ $label }}</p>
    <div class="mt-3 flex items-end justify-between gap-2">
        <p class="text-2xl font-extrabold leading-tight">{{ $value }}</p>
        @if ($badge)
            <span class="whitespace-nowrap text-xs font-bold text-[#2F5D34]">{{ $badge }}</span>
        @endif
    </div>
</div>