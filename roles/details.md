<!DOCTYPE html>

<html class="light" lang="pt-PT"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface": "#f7f9fb",
                        "on-secondary": "#ffffff",
                        "primary-container": "#002b5b",
                        "error": "#ba1a1a",
                        "surface-variant": "#e0e3e5",
                        "on-secondary-container": "#fefcff",
                        "primary-fixed": "#d6e3ff",
                        "surface-dim": "#d8dadc",
                        "surface-container-highest": "#e0e3e5",
                        "primary": "#001736",
                        "on-primary-fixed-variant": "#264778",
                        "error-container": "#ffdad6",
                        "on-tertiary": "#ffffff",
                        "on-tertiary-container": "#8495ad",
                        "tertiary-container": "#1d2d41",
                        "on-tertiary-fixed-variant": "#38485d",
                        "on-primary": "#ffffff",
                        "tertiary-fixed": "#d3e4fe",
                        "outline-variant": "#c4c6d0",
                        "on-secondary-fixed": "#00174b",
                        "inverse-surface": "#2d3133",
                        "on-background": "#191c1e",
                        "primary-fixed-dim": "#a9c7ff",
                        "secondary-fixed-dim": "#b4c5ff",
                        "surface-bright": "#f7f9fb",
                        "tertiary": "#07182b",
                        "on-primary-container": "#7594ca",
                        "secondary-container": "#316bf3",
                        "inverse-on-surface": "#eff1f3",
                        "on-secondary-fixed-variant": "#003ea8",
                        "inverse-primary": "#a9c7ff",
                        "on-error-container": "#93000a",
                        "outline": "#747780",
                        "secondary": "#0051d5",
                        "on-surface-variant": "#43474f",
                        "on-primary-fixed": "#001b3d",
                        "background": "#f7f9fb",
                        "surface-container-high": "#e6e8ea",
                        "tertiary-fixed-dim": "#b7c8e1",
                        "secondary-fixed": "#dbe1ff",
                        "on-error": "#ffffff",
                        "on-tertiary-fixed": "#0b1c30",
                        "surface-container-low": "#f2f4f6",
                        "surface-container-lowest": "#ffffff",
                        "surface-container": "#eceef0",
                        "on-surface": "#191c1e",
                        "surface-tint": "#405f91"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "md": "16px",
                        "xs": "4px",
                        "xl": "32px",
                        "gutter": "16px",
                        "xxl": "48px",
                        "unit": "4px",
                        "sm": "8px",
                        "lg": "24px",
                        "margin-mobile": "20px"
                    },
                    "fontFamily": {
                        "headline-sm": ["Manrope"],
                        "label-lg": ["Inter"],
                        "headline-md": ["Manrope"],
                        "display-lg": ["Manrope"],
                        "headline-lg-mobile": ["Manrope"],
                        "headline-lg": ["Manrope"],
                        "label-sm": ["Inter"],
                        "body-lg": ["Inter"],
                        "body-md": ["Inter"]
                    },
                    "fontSize": {
                        "headline-sm": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                        "label-lg": ["14px", {"lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "600"}],
                        "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                        "display-lg": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                        "headline-lg-mobile": ["28px", {"lineHeight": "36px", "fontWeight": "700"}],
                        "headline-lg": ["32px", {"lineHeight": "40px", "fontWeight": "700"}],
                        "label-sm": ["12px", {"lineHeight": "16px", "fontWeight": "500"}],
                        "body-lg": ["18px", {"lineHeight": "28px", "fontWeight": "400"}],
                        "body-md": ["16px", {"lineHeight": "24px", "fontWeight": "400"}]
                    }
                }
            }
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        body { background-color: #f7f9fb; }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-body-md text-on-background">
<!-- Top Navigation Bar -->
<nav class="bg-surface text-primary font-headline-md text-headline-md flex justify-between items-center px-margin-mobile h-14 w-full docked full-width top-0 z-40">
<div class="flex items-center gap-md">
<span class="material-symbols-outlined text-primary cursor-pointer active:scale-95 transition-transform duration-150">close</span>
<span class="font-bold tracking-tight">Mobilidade Premium</span>
</div>
<div class="w-8 h-8 rounded-full overflow-hidden border border-outline-variant">
<img alt="Foto de Perfil" class="w-full h-full object-cover" data-alt="A professional studio portrait of a business executive with a friendly expression. The lighting is soft and directional, typical of a high-end corporate photoshoot. The background is a clean, neutral grey that complements the modern and corporate aesthetic of the app, emphasizing trust and precision." src="https://lh3.googleusercontent.com/aida-public/AB6AXuACTKkExMfq4ODyTbTGrxQquONkIm-LRQwhzTgFdk27RymxVuYHqzvOuZ7MmReRedn0xqaLC1iZecnP81CfK2e0954yUoCy-nFQ0401gFnn3hynMD08bd7JKumWq2J98gouHN9-D4T_MURPxgCbZCjQ4_HH276pfVNrM1pe1TKEmX7vktZmMnlkuOcwmsydi5Y2DLxFcZxP0_Y6I0dZhjVHkQIsNnRtN9OUxtl8P5rbcqmUEKhWkvGUMhyqkmlrKtPkV0Cszfny2RU"/>
</div>
</nav>
<main class="max-w-4xl mx-auto px-margin-mobile pt-lg pb-xxl">
<!-- Success State Header -->
<div class="flex flex-col items-center text-center mb-xl">
<div class="w-20 h-20 bg-secondary-container rounded-full flex items-center justify-center mb-md shadow-lg">
<span class="material-symbols-outlined text-[40px] text-on-secondary-container" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<h1 class="font-headline-lg text-headline-lg text-primary mb-xs">Viagem Concluída!</h1>
<p class="font-body-lg text-body-lg text-on-surface-variant">Obrigado por viajar connosco.</p>
</div>
<!-- Summary & Feedback Bento Grid -->
<div class="grid grid-cols-1 md:grid-cols-12 gap-lg">
<!-- Trip Summary Card -->
<div class="md:col-span-7 bg-surface-container-lowest rounded-xl p-lg shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<h2 class="font-headline-sm text-headline-sm text-primary mb-md">Resumo da Viagem</h2>
<div class="flex items-center justify-between py-md border-b border-surface-variant">
<div class="flex items-center gap-md">
<div class="w-10 h-10 bg-surface-container rounded-lg flex items-center justify-center text-secondary">
<span class="material-symbols-outlined">payments</span>
</div>
<span class="font-label-lg text-label-lg text-on-surface-variant">Preço Final</span>
</div>
<span class="font-headline-md text-headline-md text-primary">12,45€</span>
</div>
<div class="grid grid-cols-2 gap-md mt-md">
<div class="bg-surface-container-low p-md rounded-lg">
<span class="font-label-sm text-label-sm text-on-surface-variant block mb-xs uppercase tracking-wider">Distância</span>
<div class="flex items-end gap-xs">
<span class="font-headline-sm text-headline-sm text-primary">8.4</span>
<span class="font-label-lg text-label-lg text-on-surface-variant pb-1">km</span>
</div>
</div>
<div class="bg-surface-container-low p-md rounded-lg">
<span class="font-label-sm text-label-sm text-on-surface-variant block mb-xs uppercase tracking-wider">Duração</span>
<div class="flex items-end gap-xs">
<span class="font-headline-sm text-headline-sm text-primary">18</span>
<span class="font-label-lg text-label-lg text-on-surface-variant pb-1">min</span>
</div>
</div>
</div>
<!-- Map Preview -->
<div class="mt-lg h-40 w-full rounded-lg overflow-hidden relative">
<img alt="Mapa do trajeto" class="w-full h-full object-cover" data-location="Lisbon" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCft7yamMQSNX6cFwnXfHACDZHgPRzUz5JAjCMlBrfK4OgsAlPpGUDqbwWaPdverwm-EIGyN2xYL_MHLYatS0XpcwcoC0d5IfD0EdpZ3tY6v-9fzQVuN0pD8NjnackJRnJimMXR2sW1Xa7BUz1T3DJQWNX5Sjrkw5Qh5JS3BIbMuEPhz8_biwEF95XV4PoQG4jKO7G0KiuD9HAauGfFlZCPwuar496YEobXZx-bGJDiyQGWojQHHIuh1gsTgRm5yw3YEPGY-2ogrYQ"/>
<div class="absolute inset-0 bg-primary/10 flex items-center justify-center">
<div class="bg-white/90 backdrop-blur-sm px-md py-sm rounded-full flex items-center gap-sm shadow-md">
<span class="material-symbols-outlined text-secondary text-md">route</span>
<span class="font-label-lg text-label-lg text-primary">Trajeto otimizado</span>
</div>
</div>
</div>
</div>
<!-- Feedback & Rating Card -->
<div class="md:col-span-5 bg-surface-container-lowest rounded-xl p-lg shadow-[0_2px_8px_rgba(0,23,54,0.04)] flex flex-col">
<h2 class="font-headline-sm text-headline-sm text-primary mb-md">Avalie a Viagem</h2>
<p class="font-body-md text-body-md text-on-surface-variant mb-lg">Como correu a sua experiência com o motorista e o veículo?</p>
<!-- 5-Star Rating -->
<div class="flex justify-between items-center mb-xl px-sm">
<span class="material-symbols-outlined text-[32px] text-secondary cursor-pointer hover:scale-110 transition-transform" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-[32px] text-secondary cursor-pointer hover:scale-110 transition-transform" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-[32px] text-secondary cursor-pointer hover:scale-110 transition-transform" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-[32px] text-secondary cursor-pointer hover:scale-110 transition-transform" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined text-[32px] text-outline-variant cursor-pointer hover:scale-110 transition-transform">star</span>
</div>
<!-- Feedback Text -->
<div class="flex-grow">
<label class="block font-label-lg text-label-lg text-on-surface mb-sm">Comentário (opcional)</label>
<textarea class="w-full h-32 bg-surface border border-outline-variant rounded-lg p-md font-body-md focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all resize-none" placeholder="Partilhe a sua opinião..."></textarea>
</div>
<button class="w-full h-14 mt-lg bg-secondary text-on-secondary font-label-lg text-label-lg rounded-full flex items-center justify-center gap-sm active:scale-95 transition-all duration-200">
                    Enviar avaliação
                </button>
</div>
</div>
<!-- Action Grid Below Summary -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-lg mt-lg">
<button class="h-14 bg-surface-container-high text-on-surface-variant font-label-lg text-label-lg rounded-full flex items-center justify-center gap-sm border border-outline-variant hover:bg-surface-variant active:scale-95 transition-all duration-200">
<span class="material-symbols-outlined">report_problem</span>
                Reportar problema
            </button>
<button class="h-14 bg-primary text-on-primary font-label-lg text-label-lg rounded-full flex items-center justify-center gap-sm active:scale-95 transition-all duration-200">
<span class="material-symbols-outlined">home</span>
                Voltar ao início
            </button>
</div>
</main>
<!-- Bottom Navigation Bar (Contextual Check: Suppressed on Success Screen per rules, but included if top-level destination. Here it acts as a confirmation splash, so shell is hidden for focus.) -->
</body></html>