<!DOCTYPE html>

<html lang="pt"><head>
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
                    "on-tertiary-container": "#8495ad",
                    "on-secondary-container": "#fefcff",
                    "inverse-primary": "#a9c7ff",
                    "tertiary": "#07182b",
                    "surface-container-high": "#e6e8ea",
                    "secondary-container": "#316bf3",
                    "on-error-container": "#93000a",
                    "inverse-surface": "#2d3133",
                    "primary": "#001736",
                    "error": "#ba1a1a",
                    "surface-dim": "#d8dadc",
                    "error-container": "#ffdad6",
                    "surface-bright": "#f7f9fb",
                    "tertiary-fixed-dim": "#b7c8e1",
                    "on-tertiary": "#ffffff",
                    "secondary": "#0051d5",
                    "on-primary-container": "#7594ca",
                    "inverse-on-surface": "#eff1f3",
                    "surface-variant": "#e0e3e5",
                    "surface": "#f7f9fb",
                    "outline-variant": "#c4c6d0",
                    "on-primary": "#ffffff",
                    "primary-fixed-dim": "#a9c7ff",
                    "on-tertiary-fixed": "#0b1c30",
                    "surface-container": "#eceef0",
                    "background": "#f7f9fb",
                    "on-secondary": "#ffffff",
                    "outline": "#747780",
                    "secondary-fixed-dim": "#b4c5ff",
                    "surface-container-low": "#f2f4f6",
                    "surface-container-highest": "#e0e3e5",
                    "on-background": "#191c1e",
                    "on-primary-fixed": "#001b3d",
                    "primary-container": "#002b5b",
                    "on-surface": "#191c1e",
                    "on-error": "#ffffff",
                    "on-secondary-fixed": "#00174b",
                    "on-tertiary-fixed-variant": "#38485d",
                    "tertiary-fixed": "#d3e4fe",
                    "surface-container-lowest": "#ffffff",
                    "secondary-fixed": "#dbe1ff",
                    "tertiary-container": "#1d2d41",
                    "primary-fixed": "#d6e3ff",
                    "on-surface-variant": "#43474f",
                    "surface-tint": "#405f91",
                    "on-primary-fixed-variant": "#264778",
                    "on-secondary-fixed-variant": "#003ea8"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "gutter": "16px",
                    "xxl": "48px",
                    "margin-mobile": "20px",
                    "xs": "4px",
                    "lg": "24px",
                    "unit": "4px",
                    "md": "16px",
                    "sm": "8px",
                    "xl": "32px"
            },
            "fontFamily": {
                    "headline-lg": ["Manrope"],
                    "label-sm": ["Inter"],
                    "display-lg": ["Manrope"],
                    "headline-sm": ["Manrope"],
                    "body-md": ["Inter"],
                    "label-lg": ["Inter"],
                    "body-lg": ["Inter"],
                    "headline-md": ["Manrope"],
                    "headline-lg-mobile": ["Manrope"]
            },
            "fontSize": {
                    "headline-lg": ["32px", {"lineHeight": "40px", "fontWeight": "700"}],
                    "label-sm": ["12px", {"lineHeight": "16px", "fontWeight": "500"}],
                    "display-lg": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "headline-sm": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "body-md": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "label-lg": ["14px", {"lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "600"}],
                    "body-lg": ["18px", {"lineHeight": "28px", "fontWeight": "400"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                    "headline-lg-mobile": ["28px", {"lineHeight": "36px", "fontWeight": "700"}]
            }
          },
        },
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-md selection:bg-secondary-container selection:text-on-secondary-container">
<!-- TopAppBar -->
<header class="bg-surface sticky top-0 z-50 flex justify-between items-center px-margin-mobile h-14 w-full">
<div class="flex items-center gap-md">
<button class="hover:bg-surface-container-low p-2 rounded-full transition-transform active:scale-95 duration-150">
<span class="material-symbols-outlined text-primary">arrow_back</span>
</button>
<h1 class="font-headline-md text-headline-md font-bold text-primary">Revisão da Reserva</h1>
</div>
<div class="flex items-center gap-sm">
<img alt="Foto de Perfil" class="w-8 h-8 rounded-full border border-outline-variant" data-alt="A professional and clean headshot of a person with a friendly expression, set against a neutral, high-key studio background. The lighting is soft and even, emphasizing a modern corporate aesthetic. The overall color palette is composed of soft whites and cool greys, reflecting a premium and trustworthy digital identity." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCur2vBKigrqN5nIfIJ6cppRv3gGe8zRJkSA2RsbcgGDOy33Tf-rgtRbRheKwRImT4ygWhO3eTrlG6OSSiE4neL_Un3CDd2QqssSJloUjCW9KryI-VywbhRrr3ABvftKvfQmHYormtjQW4Tv6Jjore08BrXaV5IwbHZq66_AsIx7Er__fVi5e91Mds4fZ_2kBWHfYUHGWQFRHS7SdGzorvz2B0X1PmOoZQLHJKk2KVtp54ViQrggD7Z6WgorwyPHl7OZo2H1vT5GY4"/>
</div>
</header>
<main class="max-w-4xl mx-auto px-margin-mobile pt-lg pb-xxl">
<div class="grid grid-cols-1 lg:grid-cols-12 gap-lg">
<!-- Left Column: Details & Vehicle -->
<div class="lg:col-span-7 space-y-lg">
<!-- Vehicle Card -->
<section class="bg-surface-container-lowest rounded-xl p-lg shadow-[0_2px_8px_rgba(0,23,54,0.04)] overflow-hidden">
<div class="flex flex-col md:flex-row gap-lg">
<div class="md:w-1/3">
<img alt="Veículo Premium" class="w-full h-auto rounded-lg object-cover" data-alt="A sleek, modern electric sedan in a metallic dark blue finish, parked in a minimalist architectural environment with clean lines and soft daylight. The car's design is premium and sophisticated, with elegant curves and polished surfaces. The lighting highlights the vehicle's metallic texture, creating a sense of luxury and technological advancement." src="https://lh3.googleusercontent.com/aida-public/AB6AXuADBMwgF_iddnHo8D6-rjYZYu5Dg_irhSStLQBwSNWuF5lZElbh-DQTsj2JzZG9CR8rcP-PIjFZy4M2YA2t59PWyObzOY-puNiPraxYYQtwV_bwWBCnohiYtGiNv_aFwXNSXRvu8o-KXjWtel1svZUQ3aeocRIkF42vURyAKc124eey1biQB9cZ8o1L4k5bHYDQQ9qhD_HfDYQcMjVYTeDiKO3nQSzEc6-rhwppMGDw4TlahAVARIJgwbCAsG4aO5Y6bphFEob-IuM"/>
</div>
<div class="md:w-2/3">
<div class="flex justify-between items-start">
<div>
<h2 class="font-headline-sm text-headline-sm text-primary">Tesla Model 3 Performance</h2>
<p class="text-on-surface-variant font-body-md">Elétrico • 5 Lugares • Automático</p>
</div>
<span class="bg-secondary-container/10 text-secondary px-sm py-xs rounded font-label-lg text-label-lg">Premium</span>
</div>
<div class="mt-md flex items-center gap-sm text-on-surface-variant">
<span class="material-symbols-outlined text-[20px]">verified</span>
<span class="text-label-lg font-label-lg">Seguro Total Incluído</span>
</div>
</div>
</div>
</section>
<!-- Itinerary Details -->
<section class="bg-surface-container-lowest rounded-xl p-lg shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<h3 class="font-headline-sm text-headline-sm text-primary mb-md">Itinerário</h3>
<div class="relative space-y-lg">
<div class="flex gap-md">
<div class="flex flex-col items-center">
<span class="material-symbols-outlined text-secondary">location_on</span>
<div class="w-0.5 h-full bg-outline-variant my-xs"></div>
</div>
<div>
<p class="text-label-sm font-label-sm text-on-surface-variant">LEVANTAMENTO</p>
<p class="font-body-md font-semibold text-on-surface">Aeroporto de Lisboa (LIS)</p>
<p class="text-label-lg font-label-lg text-on-surface-variant">15 Out, 2023 às 10:00</p>
</div>
</div>
<div class="flex gap-md">
<div class="flex flex-col items-center">
<span class="material-symbols-outlined text-primary">flag</span>
</div>
<div>
<p class="text-label-sm font-label-sm text-on-surface-variant">DEVOLUÇÃO</p>
<p class="font-body-md font-semibold text-on-surface">Aeroporto de Lisboa (LIS)</p>
<p class="text-label-lg font-label-lg text-on-surface-variant">20 Out, 2023 às 18:00</p>
</div>
</div>
</div>
</section>
<!-- Security & Trust -->
<div class="flex items-center gap-md p-md bg-surface-container-low rounded-lg border border-outline-variant/30">
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">security</span>
<div>
<p class="font-label-lg text-label-lg text-primary">Pagamento 100% Seguro</p>
<p class="text-label-sm font-label-sm text-on-surface-variant">Utilizamos encriptação SSL de 256 bits para proteger os seus dados.</p>
</div>
</div>
</div>
<!-- Right Column: Summary & Payment -->
<aside class="lg:col-span-5 space-y-lg">
<!-- Cost Breakdown Card -->
<div class="bg-surface-container-lowest rounded-xl p-lg shadow-[0_4px_16px_rgba(0,23,54,0.08)] sticky top-20 border border-outline-variant/20">
<h3 class="font-headline-sm text-headline-sm text-primary mb-lg">Resumo de Custos</h3>
<div class="space-y-sm">
<div class="flex justify-between font-body-md">
<span class="text-on-surface-variant">Aluguer (5 dias)</span>
<span class="text-on-surface">345,00 €</span>
</div>
<div class="flex justify-between font-body-md">
<span class="text-on-surface-variant">Taxas de Aeroporto</span>
<span class="text-on-surface">24,50 €</span>
</div>
<div class="flex justify-between font-body-md">
<span class="text-on-surface-variant">Cadeira de Criança (Extra)</span>
<span class="text-on-surface">15,00 €</span>
</div>
<div class="flex justify-between font-body-md">
<span class="text-on-surface-variant">IVA (23%)</span>
<span class="text-on-surface">88,44 €</span>
</div>
</div>
<div class="my-lg border-t border-dashed border-outline-variant"></div>
<div class="flex justify-between items-center mb-xl">
<span class="font-headline-sm text-headline-sm text-primary">Total</span>
<div class="text-right">
<span class="block font-headline-md text-headline-md text-secondary font-bold">472,94 €</span>
<span class="text-label-sm font-label-sm text-on-surface-variant">Sem custos ocultos</span>
</div>
</div>
<!-- Payment Methods -->
<div class="space-y-md mb-xl">
<p class="font-label-lg text-label-lg text-primary">Método de Pagamento</p>
<label class="flex items-center justify-between p-md rounded-lg border-2 border-secondary-container bg-surface-container-low cursor-pointer transition-all">
<div class="flex items-center gap-md">
<span class="material-symbols-outlined text-secondary-container" style="font-variation-settings: 'FILL' 1;">credit_card</span>
<div>
<p class="font-label-lg text-label-lg text-primary">Cartão de Crédito</p>
<p class="text-label-sm font-label-sm text-on-surface-variant">•••• •••• •••• 4242</p>
</div>
</div>
<div class="w-5 h-5 rounded-full border-4 border-secondary-container bg-white"></div>
</label>
<button class="w-full flex items-center justify-center gap-md p-md rounded-lg border border-outline-variant hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined text-primary">ios</span>
<span class="font-label-lg text-label-lg text-primary">Pagar com Apple Pay</span>
</button>
</div>
<!-- CTA Button -->
<button class="w-full bg-secondary text-white py-lg rounded-xl font-headline-sm text-headline-sm hover:bg-primary transition-all active:scale-95 flex items-center justify-center gap-sm shadow-lg shadow-secondary/20">
                        Confirmar e Pagar
                        <span class="material-symbols-outlined">chevron_right</span>
</button>
<p class="text-center text-label-sm font-label-sm text-on-surface-variant mt-md">
                        Ao clicar em "Confirmar e Pagar", aceita os nossos <a class="underline text-secondary" href="#">Termos e Condições</a>.
                    </p>
</div>
</aside>
</div>
</main>
<!-- Bottom Navigation (Contextual Suppression Logic applied, but placeholder kept if needed by architecture - though in transactional screen it should be hidden according to instructions) -->
<!-- Navigation hidden for transactional focus as per shell visibility rule -->
<!-- Confirmation Modal Overlay (Hidden by default) -->
<div class="fixed inset-0 bg-black/40 z-[100] hidden flex items-center justify-center backdrop-blur-sm">
<div class="bg-surface-container-lowest p-xl rounded-2xl max-w-md w-full mx-margin-mobile shadow-2xl">
<div class="w-16 h-16 bg-secondary/10 text-secondary rounded-full flex items-center justify-center mx-auto mb-lg">
<span class="material-symbols-outlined text-4xl" style="font-variation-settings: 'wght' 700;">check_circle</span>
</div>
<h4 class="font-headline-md text-headline-md text-primary text-center mb-sm">Reserva Confirmada!</h4>
<p class="text-body-md text-on-surface-variant text-center mb-xl">O seu Tesla Model 3 estará à sua espera no Aeroporto de Lisboa.</p>
<button class="w-full bg-primary text-white py-md rounded-lg font-label-lg text-label-lg">Ver Bilhete</button>
</div>
</div>
</body></html>