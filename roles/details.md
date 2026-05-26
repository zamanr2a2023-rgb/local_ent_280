<!DOCTYPE html><html class="light" lang="pt-PT"><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Manrope:wght@600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet">
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
          },
        },
      }
    </script>
<style>
        .map-gradient-overlay {
            background: linear-gradient(to bottom, rgba(247, 249, 251, 0) 0%, rgba(247, 249, 251, 1) 100%);
        }
        .custom-shadow {
            box-shadow: 0 2px 8px rgba(0, 23, 54, 0.04);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface font-body-md text-on-surface selection:bg-secondary-container selection:text-on-secondary-container">
<header class="bg-surface dark:bg-surface fixed top-0 w-full z-50 h-14 flex justify-between items-center px-margin-mobile">
<div class="flex items-center gap-md">
<button class="text-primary hover:bg-surface-container-low p-sm rounded-full transition-transform active:scale-95 duration-150">
<span class="material-symbols-outlined">arrow_back</span>
</button>
<h1 class="font-headline-md text-headline-md font-bold text-primary">Mobilidade Premium</h1>
</div>
<div class="h-8 w-8 rounded-full bg-surface-variant overflow-hidden border border-outline-variant">
<img alt="Foto de Perfil" class="h-full w-full object-cover" data-alt="A professional headshot of a middle-aged man with a friendly expression, set against a blurred corporate office background. The lighting is soft and professional, emphasizing a modern light-mode aesthetic. The color palette is clean with neutral tones and soft blue accents, conveying reliability and executive quality in a premium mobility service context." src="https://lh3.googleusercontent.com/aida-public/AB6AXuABzCif6cxQWIO1_nOOZZBSF8eBxDyedY24paDCOmNzqqzkhVcmgOWXsBScRA2kdIjm9Si5E7F4FLGpXfsxSwo1mQSj3KIq4Q3qaXmMb9KgcsbLEwGMVq_bV5NALuD6eqmxSQ8fFt7_V-l0l9EO6gPc28eF5WJmVlxGUTkFOeMBZL1qPrrQue5D68TWgMPs0Y35Cxu4V6bgrw_ndQ_rX1QV3KzsGPMCbqyeBi2utrjTpObmlpv10LDvqbMeKqkutD5IfMV-MRXzu4Q">
</div>
</header>
<main class="pt-14 pb-xxl max-w-5xl mx-auto px-gutter md:px-margin-mobile">
<div class="grid grid-cols-1 md:grid-cols-12 gap-lg mt-md">
<div class="md:col-span-7 space-y-md">
<div class="relative h-64 md:h-80 w-full rounded-xl overflow-hidden custom-shadow">
<img class="w-full h-full object-cover" data-alt="A detailed digital map of Lisbon's central district showcasing a highlighted premium transport route with smooth blue lines. The map uses a minimalist, light-themed aesthetic with soft grays and blues to ensure high legibility. The surrounding city blocks are rendered in a clean, professional architectural style, reflecting a sense of precision and urban mobility." data-location="Lisbon" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBBnN-KGtFYMXh7zxMZXZFT9drU4aNWJerQKv6JV5ABP2aUXW6ZyehaQbjiPR9atQdUs3KYzzpAHM-QOK8ulLN2kve5xn2bxyJ6XBy5D_1Zu3aBh_BDLliZwJU8O4Ez87wVQKmJQWOH4Hc6ifptJsFZ13unRYykw1NfY10gicXYE3GspzYyauh8kYnB4fXXp4HKGf_NBn9K3Qn9BHIuZ2_ZdSN9rx-deawIsFOLkVgqaVvMJ86-t4wbspW48wWS8B__PYzk-mkx4hk">
<div class="absolute inset-0 map-gradient-overlay pointer-events-none"></div>
<div class="absolute bottom-md left-md bg-surface-container-lowest px-md py-sm rounded-lg custom-shadow flex items-center gap-sm">
<span class="material-symbols-outlined text-secondary text-sm">schedule</span>
<span class="font-label-lg text-label-lg">24 min • 12.5 km</span>
</div>
</div>
<div class="bg-surface-container-lowest p-lg rounded-xl custom-shadow space-y-md">
<div class="flex justify-between items-start">
<div>
<h2 class="font-headline-sm text-headline-sm text-primary">Resumo da Viagem</h2>
<p class="font-label-sm text-label-sm text-on-surface-variant">14 de Outubro, 2023 • 18:42</p>
</div>
<span class="bg-secondary-container text-on-secondary-container px-md py-xs rounded-full font-label-sm text-label-sm">Concluída</span>
</div>
<div class="space-y-sm relative pl-8">
<div class="absolute left-3 top-2 bottom-2 w-0.5 bg-outline-variant"></div>
<div class="relative">
<span class="material-symbols-outlined absolute -left-8 text-secondary bg-surface-container-lowest" style="font-variation-settings: 'FILL' 1;">location_on</span>
<p class="font-label-lg text-label-lg text-on-surface">Avenida da Liberdade, 110</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">Lisboa, Portugal</p>
</div>
<div class="relative pt-md">
<span class="material-symbols-outlined absolute -left-8 text-primary bg-surface-container-lowest" style="font-variation-settings: 'FILL' 1;">trip_origin</span>
<p class="font-label-lg text-label-lg text-on-surface">Aeroporto Humberto Delgado</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">Terminal 1, Partidas</p>
</div>
</div>
</div>
<div class="bg-surface-container-lowest p-lg rounded-xl custom-shadow">
<h3 class="font-label-lg text-label-lg text-primary mb-md">Avalie a sua experiência</h3>
<div class="flex justify-between items-center bg-surface-container-low p-md rounded-lg">
<div class="flex gap-xs text-secondary">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="material-symbols-outlined">star</span>
</div>
<button class="text-secondary font-label-lg text-label-lg hover:underline transition-all">Editar</button>
</div>
</div>
</div>
<div class="md:col-span-5 space-y-md">
<div class="bg-surface-container-lowest p-lg rounded-xl custom-shadow border-t-4 border-secondary">
<div class="flex justify-between items-center mb-lg">
<h2 class="font-headline-sm text-headline-sm text-primary">Fatura Digital</h2>
<span class="material-symbols-outlined text-on-surface-variant">receipt_long</span>
</div>
<div class="space-y-sm">
<div class="flex justify-between">
<span class="text-on-surface-variant font-body-md text-body-md">Tarifa Base</span>
<span class="font-label-lg text-label-lg">3,50 €</span>
</div>
<div class="flex justify-between">
<span class="text-on-surface-variant font-body-md text-body-md">Distância (12.5 km)</span>
<span class="font-label-lg text-label-lg">14,25 €</span>
</div>
<div class="flex justify-between">
<span class="text-on-surface-variant font-body-md text-body-md">Tempo (24 min)</span>
<span class="font-label-lg text-label-lg">4,80 €</span>
</div>
<div class="flex justify-between text-secondary">
<span class="font-body-md text-body-md">Desconto Promocional</span>
<span class="font-label-lg text-label-lg">- 2,50 €</span>
</div>
<div class="border-t border-outline-variant my-md pt-md flex justify-between items-end">
<div>
<p class="font-label-sm text-label-sm text-on-surface-variant">Total Pago</p>
<p class="font-display-lg text-display-lg text-primary">20,05 €</p>
</div>
<div class="text-right">
<p class="font-label-sm text-label-sm text-on-surface-variant">Método</p>
<div class="flex items-center gap-xs">
<span class="material-symbols-outlined text-sm">credit_card</span>
<span class="font-label-lg text-label-lg">Visa •••• 4242</span>
</div>
</div>
</div>
</div>
<button class="w-full mt-lg bg-surface-container-low text-primary py-md rounded-xl font-label-lg text-label-lg hover:bg-surface-container-high transition-all active:scale-95 flex items-center justify-center gap-sm">
<span class="material-symbols-outlined text-lg">download</span>
                        Descarregar PDF
                    </button>
</div>
<div class="bg-surface-container-lowest p-lg rounded-xl custom-shadow flex items-center gap-lg">
<div class="relative">
<div class="h-16 w-16 rounded-full bg-surface-variant overflow-hidden border-2 border-secondary">
<img alt="Motorista" class="h-full w-full object-cover" data-alt="A high-quality portrait of a professional driver wearing a clean dark uniform, smiling warmly. The image is crisp and clear, set against a soft bokeh of city lights at dusk. The overall aesthetic is professional, secure, and premium, using a color palette of deep blues and warm highlights to evoke trust and high-end service." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXlihrW5Db1arRHJt09rshKogObdFEVnTfZlPzdYWK2139TFPJXMC8v8l1dhEQD4nIsiC96t8ujPdTLrs8xkyEH8cRSBM2AWd6aO-hFOIlIS6hU-dDAlLY9l8UPPEi28Fz6umOR2XX0nQGDtto6FQX0rsYTSFbc7aRQ56G4sJX1VifRL-RC9ds9xeWQY06VRABSaq4O3L7-Zw9Vy-updxVLmogXbpSARtQBMpIXBsklOn-Leeq0kwpKUkdq90IkFVGvht2Eoq9DCs">
</div>
<div class="absolute -bottom-1 -right-1 bg-secondary text-on-secondary h-6 w-6 rounded-full flex items-center justify-center text-[10px] font-bold">4.9</div>
</div>
<div class="flex-1">
<h3 class="font-headline-sm text-headline-sm text-primary">Ricardo Santos</h3>
<p class="font-body-md text-body-md text-on-surface-variant">Tesla Model 3 • 42-XG-99</p>
<p class="font-label-sm text-label-sm text-secondary">Premium Electric</p>
</div>
</div>
<div class="bg-surface-container-lowest p-lg rounded-xl custom-shadow border border-error-container">
<div class="flex items-center gap-md mb-md">
<span class="material-symbols-outlined text-error">report</span>
<h3 class="font-label-lg text-label-lg text-primary">Algo correu mal?</h3>
</div>
<button class="w-full text-left text-on-surface-variant font-body-md text-body-md hover:text-error transition-colors flex justify-between items-center py-sm">
<span class="">Reportar objeto perdido</span>
<span class="material-symbols-outlined text-sm">chevron_right</span>
</button>
<button class="w-full text-left text-on-surface-variant font-body-md text-body-md hover:text-error transition-colors flex justify-between items-center py-sm">
<span class="">Reclamação de segurança</span>
<span class="material-symbols-outlined text-sm">chevron_right</span>
</button>
<button class="w-full text-left text-on-surface-variant font-body-md text-body-md hover:text-error transition-colors flex justify-between items-center py-sm">
<span class="">Apoio ao cliente</span>
<span class="material-symbols-outlined text-sm">chevron_right</span>
</button>
</div>
</div>
</div>
</main>



</body></html>