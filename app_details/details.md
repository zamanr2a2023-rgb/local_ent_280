<!DOCTYPE html>

<html class="light" lang="pt-PT"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Manrope:wght@600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#07182b",
                        "inverse-primary": "#a9c7ff",
                        "surface-variant": "#e0e3e5",
                        "primary-container": "#002b5b",
                        "on-surface-variant": "#43474f",
                        "on-tertiary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "surface-bright": "#f7f9fb",
                        "tertiary-container": "#1d2d41",
                        "secondary-container": "#316bf3",
                        "tertiary-fixed-dim": "#b7c8e1",
                        "on-tertiary-container": "#8495ad",
                        "on-secondary-fixed-variant": "#003ea8",
                        "tertiary-fixed": "#d3e4fe",
                        "secondary-fixed": "#dbe1ff",
                        "on-tertiary-fixed": "#0b1c30",
                        "on-primary-fixed-variant": "#264778",
                        "on-error-container": "#93000a",
                        "on-secondary-container": "#fefcff",
                        "primary-fixed-dim": "#a9c7ff",
                        "secondary": "#0051d5",
                        "on-background": "#191c1e",
                        "inverse-surface": "#2d3133",
                        "on-error": "#ffffff",
                        "background": "#f7f9fb",
                        "primary-fixed": "#d6e3ff",
                        "surface-container": "#eceef0",
                        "outline": "#747780",
                        "surface-container-low": "#f2f4f6",
                        "surface-container-high": "#e6e8ea",
                        "secondary-fixed-dim": "#b4c5ff",
                        "on-primary-fixed": "#001b3d",
                        "on-primary": "#ffffff",
                        "surface-tint": "#405f91",
                        "primary": "#001736",
                        "surface-dim": "#d8dadc",
                        "outline-variant": "#c4c6d0",
                        "on-primary-container": "#7594ca",
                        "surface": "#f7f9fb",
                        "on-surface": "#191c1e",
                        "on-tertiary-fixed-variant": "#38485d",
                        "inverse-on-surface": "#eff1f3",
                        "on-secondary": "#ffffff",
                        "error-container": "#ffdad6",
                        "surface-container-highest": "#e0e3e5",
                        "on-secondary-fixed": "#00174b",
                        "error": "#ba1a1a"
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
                        "sm": "8px",
                        "gutter": "16px",
                        "xl": "32px",
                        "unit": "4px",
                        "lg": "24px",
                        "margin-mobile": "20px",
                        "xxl": "48px"
                    },
                    "fontFamily": {
                        "headline-lg": ["Manrope"],
                        "body-lg": ["Inter"],
                        "body-md": ["Inter"],
                        "label-sm": ["Inter"],
                        "headline-sm": ["Manrope"],
                        "headline-lg-mobile": ["Manrope"],
                        "headline-md": ["Manrope"],
                        "display-lg": ["Manrope"],
                        "label-lg": ["Inter"]
                    },
                    "fontSize": {
                        "headline-lg": ["32px", {"lineHeight": "40px", "fontWeight": "700"}],
                        "body-lg": ["18px", {"lineHeight": "28px", "fontWeight": "400"}],
                        "body-md": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                        "label-sm": ["12px", {"lineHeight": "16px", "fontWeight": "500"}],
                        "headline-sm": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                        "headline-lg-mobile": ["28px", {"lineHeight": "36px", "fontWeight": "700"}],
                        "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                        "display-lg": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                        "label-lg": ["14px", {"lineHeight": "20px", "letterSpacing": "0.1px", "fontWeight": "600"}]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        body {
            background-color: #f7f9fb;
            color: #191c1e;
        }
        .bento-grid {
            display: grid;
            grid-template-columns: repeat(12, 1fr);
            gap: 24px;
        }
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-body-md text-body-md pb-24 md:pb-0">
<!-- Top Navigation Anchor -->
<header class="bg-surface dark:bg-surface fixed top-0 w-full z-[60] flex justify-between items-center px-margin-mobile h-14">
<div class="flex items-center gap-md">
<span class="material-symbols-outlined text-primary dark:text-primary-fixed cursor-pointer">menu</span>
<h1 class="font-headline-md text-headline-md font-bold text-primary dark:text-primary-fixed">Mobilidade Premium</h1>
</div>
<div class="w-8 h-8 rounded-full bg-surface-container-high overflow-hidden border border-outline-variant">
<img alt="Foto de Perfil" class="w-full h-full object-cover" data-alt="A professional close-up portrait of a Mediterranean man in his late 30s with a clean-shaven face and short dark hair. He is wearing a sophisticated linen shirt against a soft, out-of-focus tropical garden background. The lighting is bright and natural, reflecting a high-end travel and lifestyle aesthetic with soft shadows and warm tones." src="https://lh3.googleusercontent.com/aida-public/AB6AXuALGaP-yc0H7Owum0XuDLmqrULkudyoowADgFs887xDN1NzOJIf0SBylb45ERGKPuS2DBo3WcESKzgAKPxpj6VyE0988d2lwz0fcq3iH5pvyTFKSOJ6XfEhEGsLb7KMrTEt1DgSZTs1VC_UxOkMXoY35RjFGEwGbU8Wyubm33pgv4CU09DGioMVflO-csIu0g4KVXB5rO35VoqoGk6uHcTv_lVunKQu-eBWIeEJCqCvnR7lnKR3ieQhWWE9-eg2tO7uEvVtQg7VsJw"/>
</div>
</header>
<main class="pt-20 px-margin-mobile max-w-7xl mx-auto space-y-xxl">
<!-- Hero Section: Editorial Style -->
<section class="relative h-[530px] rounded-xl overflow-hidden shadow-lg">
<div class="absolute inset-0 bg-gradient-to-t from-primary/80 via-primary/20 to-transparent z-10"></div>
<img alt="Vista Aérea" class="absolute inset-0 w-full h-full object-cover" data-alt="A breathtaking high-angle aerial view of a secluded tropical island surrounded by crystal clear turquoise water. The coastline features pristine white sand beaches and lush green palm trees. The sunlight is vibrant and golden, creating a sense of luxury and tranquility. The overall aesthetic is clean, bright, and modern, fitting a premium travel guide." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCGlP2V3LFYt4c_5zns-Mrj57f2-o9TwyJETbdSNFQLKuchA9ri8Al-Q_4erasl7yRF4m6mcRyeaiyEuiucHikoLHx8Tl6jVrYtIy-YQT8ehDfePn1ZPWhQcikku_dzkZQkIfSm03aXE0M0YyJlFHFrTYh7fjtKm0gmv6Ssk2n0d67PXGbqe_q9KypyFkOiP6iSorH0LHpwnpUmuWY5j7NHuGCFc2_eFklfR0rz5pUSPufzNzx0YS3LITlG_tigSuGT3Vc0IKoNpho"/>
<div class="absolute bottom-0 left-0 p-lg z-20 text-on-primary max-w-2xl">
<span class="bg-secondary-container text-on-secondary-container px-sm py-xs rounded-full font-label-lg text-label-lg mb-md inline-block uppercase tracking-wider">Destaque de Verão</span>
<h2 class="font-display-lg text-display-lg mb-sm">A Essência do Mediterrâneo</h2>
<p class="font-body-lg text-body-lg text-primary-fixed-dim">Descubra refúgios secretos e experiências de luxo desenhadas para o viajante exigente.</p>
</div>
</section>
<!-- Search & Filter Bar (Map Overlay Style) -->
<div class="sticky top-16 z-40 bg-surface-container-lowest shadow-[0_4px_16px_rgba(0,23,54,0.08)] rounded-xl p-md flex flex-wrap gap-md items-center">
<div class="flex-1 flex items-center bg-surface-container-low px-md py-sm rounded-lg border border-transparent focus-within:border-primary transition-all">
<span class="material-symbols-outlined text-outline">search</span>
<input class="bg-transparent border-none focus:ring-0 w-full font-body-md ml-sm text-on-surface" placeholder="Procurar restaurantes, festas ou praias..." type="text"/>
</div>
<div class="flex gap-sm">
<button class="px-md h-12 rounded-lg bg-surface-container-high flex items-center gap-xs font-label-lg hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined text-md">filter_list</span> Filtros
                </button>
<button class="px-md h-12 rounded-lg bg-primary text-on-primary font-label-lg shadow-md hover:scale-95 transition-transform">
                    Explorar Mapa
                </button>
</div>
</div>
<!-- Bento Grid for Categories -->
<section>
<div class="flex justify-between items-end mb-lg">
<h3 class="font-headline-lg text-headline-lg text-primary">Experiências Exclusivas</h3>
<a class="text-secondary font-label-lg flex items-center gap-xs" href="#">Ver tudo <span class="material-symbols-outlined">arrow_forward</span></a>
</div>
<div class="grid grid-cols-1 md:grid-cols-12 gap-lg h-auto md:h-[500px]">
<!-- Restaurants Card -->
<div class="md:col-span-8 relative rounded-xl overflow-hidden group">
<img alt="Restaurantes" class="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" data-alt="A high-end fine dining restaurant set on a terrace overlooking the ocean at sunset. The tables are dressed in crisp white linens with elegant crystal glassware and modern ceramic plates. The lighting is a mix of warm candlelight and soft twilight. The atmosphere is sophisticated and serene, capturing a luxury Mediterranean lifestyle." src="https://lh3.googleusercontent.com/aida-public/AB6AXuClBQmRW6gk7JpgUUVn7HjQan_I4B4Fny9G77BRAIh7aAdoQ8UTKr-PB-F5zkb4oyY_q0JlnLC7YsLJaZXI0Yi6Pk0MdLVTzT9BbAH7Rp9FBW0xM6sRVjx8eTpsWk2fhmeA0dyqXXjO7rbI2Cg1Z106rsSyaVQKpATH01RSUzd511nLaTLvost4hekfNGitTPEoGd2UkL_BgA2pRhA5gxaAabclfWx4H2b7eCm7kYl78etat3ZuUXjrsWyqJxVt2QCko7qfKNumZF0"/>
<div class="absolute inset-0 bg-black/30 group-hover:bg-black/20 transition-colors"></div>
<div class="absolute bottom-0 left-0 p-lg text-white">
<p class="font-label-lg uppercase tracking-widest text-primary-fixed-dim">Gastronomia</p>
<h4 class="font-headline-md text-headline-md">Restaurantes de Autor</h4>
</div>
</div>
<!-- Places Card -->
<div class="md:col-span-4 relative rounded-xl overflow-hidden group">
<img alt="Locais" class="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" data-alt="A hidden white-sand cove with turquoise waters and dramatic limestone cliffs. A single luxury yacht is anchored in the distance. The lighting is midday bright, highlighting the vibrant colors of the nature. The visual style is crisp and editorial, evoking a sense of discovery and high-end travel exploration." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAFWR7LHILDIIjVP_8GNKQEYXZUSHIUua2dgzq-DXlVOPm_tknrm1PaB0kU2p-4Td79Id1eJWCuepfuFlx8Oh7QBCqiVjEozy-07X_6nr4BKD9UVI1iZI8j6Loc-dklbD1aXCsMV0CxTkPUfRfy6vd-lfy2umknc_3u4jphcepEOJIxy9r_Io4t5iODRK4oJNv7VEwHNvkZIXMR2J9jL87RyLaMS18Zcg5E6ApRgvIA-2rzp1ugkawVCPw_WhjRZuARSLAbraFb9DE"/>
<div class="absolute inset-0 bg-black/30 group-hover:bg-black/20 transition-colors"></div>
<div class="absolute bottom-0 left-0 p-lg text-white">
<p class="font-label-lg uppercase tracking-widest text-primary-fixed-dim">Exploração</p>
<h4 class="font-headline-md text-headline-md">Recantos Secretos</h4>
</div>
</div>
</div>
</section>
<!-- Events & Tickets Section -->
<section>
<div class="flex justify-between items-end mb-lg">
<h3 class="font-headline-lg text-headline-lg text-primary">Próximos Eventos</h3>
<div class="flex gap-xs">
<button class="w-10 h-10 rounded-full border border-outline-variant flex items-center justify-center hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined">chevron_left</span>
</button>
<button class="w-10 h-10 rounded-full border border-outline-variant flex items-center justify-center hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined">chevron_right</span>
</button>
</div>
</div>
<div class="flex overflow-x-auto gap-lg pb-md hide-scrollbar">
<!-- Event Card 1 -->
<div class="min-w-[320px] bg-surface-container-lowest rounded-xl overflow-hidden shadow-[0_2px_8px_rgba(0,23,54,0.04)] hover:shadow-lg transition-shadow border border-surface-container">
<div class="relative h-48">
<img alt="Sunset Party" class="w-full h-full object-cover" data-alt="A stylish beach club party at golden hour. Guests are seen in silhouette against a vibrant orange and pink sky. There are modern outdoor lounges, palm trees, and professional lighting rigs. The mood is energetic yet upscale, focusing on a premium electronic music event in a luxury island setting." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDrjoMJT7e5wmbcDK5UO6ZjDgXzVuRKyggOCQdNZncnJBaUVv2DrWrDACYp4W2DIkekbhy_yBLu2H1P2x2NzVJsCVrQyZBjYhHzluZ4U38Y3CVnuaeCo4YUS6KaY3WaI8mbLaqK5gCzWGjpVQfZxZq1LI_rDvs3tzkUjLuyy-C74OTSnb1L1dNS0ZOf-5hwbj_Taqj21cUi7dWhwGj68dAY-j3tYDgONH0IEGGX-ttg2FTtJNzQv30eZNKstOHUWIlb185F2eH7EDg"/>
<div class="absolute top-md right-md bg-white/90 backdrop-blur-md px-sm py-xs rounded-lg text-center">
<span class="block font-headline-sm text-primary">15</span>
<span class="block font-label-sm text-outline uppercase">AGO</span>
</div>
</div>
<div class="p-md space-y-sm">
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="font-label-lg">Blue Horizon Beach Club</span>
</div>
<h5 class="font-headline-sm text-primary">Sunset Ritual: Deep House</h5>
<p class="text-on-surface-variant line-clamp-2">Uma jornada musical inesquecível enquanto o sol se põe sobre o mar.</p>
<div class="pt-sm flex items-center justify-between">
<span class="font-headline-sm text-primary">45,00€</span>
<button class="px-lg h-12 bg-secondary-container text-on-secondary-container rounded-lg font-label-lg hover:scale-95 transition-transform flex items-center gap-xs">
                                Bilhetes <span class="material-symbols-outlined text-sm">confirmation_number</span>
</button>
</div>
</div>
</div>
<!-- Event Card 2 -->
<div class="min-w-[320px] bg-surface-container-lowest rounded-xl overflow-hidden shadow-[0_2px_8px_rgba(0,23,54,0.04)] hover:shadow-lg transition-shadow border border-surface-container">
<div class="relative h-48">
<img alt="Jazz Night" class="w-full h-full object-cover" data-alt="An intimate jazz performance in a sophisticated outdoor courtyard with ambient festoon lighting. A double bass and a saxophone are visible on a small stage. The audience is composed of elegantly dressed people at small candlelit tables. The aesthetic is warm, rich, and high-end corporate, focusing on cultural luxury." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCMHmuZDDtFas_sD_qwk5cnYcy3bPHfK-PymkS9epR3Uu4EX1AUB7NLSCke5jLEb29o11pRj72uHiUDtNFWXKphtyYDGpjwTDLsV_zH8uSLrXmzgyT_NF_UoqwMUaAm7iP33hNSlNob-DwrnvudAS3rI3kJ7DFZDD9XhDi1elToQlYcgWV3VO1nyttkAP1ttYYJVKJ1LlTvwb7XCsLySQV5DaF5pndlkUuNqvz_rTLtK80Z50iOCulYcNVuLeXZu6sJI99OKf8Nj6k"/>
<div class="absolute top-md right-md bg-white/90 backdrop-blur-md px-sm py-xs rounded-lg text-center">
<span class="block font-headline-sm text-primary">18</span>
<span class="block font-label-sm text-outline uppercase">AGO</span>
</div>
</div>
<div class="p-md space-y-sm">
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="font-label-lg">Palácio das Oliveiras</span>
</div>
<h5 class="font-headline-sm text-primary">Noites de Jazz &amp; Vinho</h5>
<p class="text-on-surface-variant line-clamp-2">Degustação premium acompanhada pelo melhor jazz contemporâneo.</p>
<div class="pt-sm flex items-center justify-between">
<span class="font-headline-sm text-primary">30,00€</span>
<button class="px-lg h-12 bg-secondary-container text-on-secondary-container rounded-lg font-label-lg hover:scale-95 transition-transform flex items-center gap-xs">
                                Bilhetes <span class="material-symbols-outlined text-sm">confirmation_number</span>
</button>
</div>
</div>
</div>
<!-- Event Card 3 -->
<div class="min-w-[320px] bg-surface-container-lowest rounded-xl overflow-hidden shadow-[0_2px_8px_rgba(0,23,54,0.04)] hover:shadow-lg transition-shadow border border-surface-container">
<div class="relative h-48">
<img alt="Full Moon Party" class="w-full h-full object-cover" data-alt="A sophisticated white-themed beach party under a full moon. Glowing decorative orbs are scattered on the sand, and people are dancing in the moonlight. The lighting is cool-toned with bright white accents. The visual style is dreamlike and luxurious, suggesting an exclusive, once-in-a-lifetime island experience." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAnBIWmPcVhj7NtbW3XjYlHLcTt0ecny7jo4vA4x-NOWnRPUokt5W3g9Wi0fc5o0pWBGLXjyJH6RfT0k39BVy_o0brksBbCrkQnWhKwDMHQW5QBMfBqDuHv_y-jMT5AHcaORStNBm1a35vmlq9F_WrBzoES3SwJPJzFUuftVaZ8TleVnXXFhFhZlE5vVhPxVOTNFc8WRxHHYHvb70B5po2QtQQUBE-UpfCD-NEkH6Gk7oDD2aRckMm9crFeubN-hcX4eG1SIwjPMyY"/>
<div class="absolute top-md right-md bg-white/90 backdrop-blur-md px-sm py-xs rounded-lg text-center">
<span class="block font-headline-sm text-primary">22</span>
<span class="block font-label-sm text-outline uppercase">AGO</span>
</div>
</div>
<div class="p-md space-y-sm">
<div class="flex items-center gap-xs text-secondary">
<span class="material-symbols-outlined text-[18px]">location_on</span>
<span class="font-label-lg">Moonlight Cove</span>
</div>
<h5 class="font-headline-sm text-primary">Full Moon White Gala</h5>
<p class="text-on-surface-variant line-clamp-2">A festa mais exclusiva da ilha. Dress code: Total White.</p>
<div class="pt-sm flex items-center justify-between">
<span class="font-headline-sm text-primary">120,00€</span>
<button class="px-lg h-12 bg-secondary-container text-on-secondary-container rounded-lg font-label-lg hover:scale-95 transition-transform flex items-center gap-xs">
                                Bilhetes <span class="material-symbols-outlined text-sm">confirmation_number</span>
</button>
</div>
</div>
</div>
</div>
</section>
<!-- Map Integration Section -->
<section class="pb-xl">
<div class="flex justify-between items-end mb-lg">
<div class="space-y-xs">
<h3 class="font-headline-lg text-headline-lg text-primary">Mapa Interativo</h3>
<p class="text-on-surface-variant">Explore os pontos de interesse perto de si.</p>
</div>
</div>
<div class="relative h-[400px] w-full rounded-xl overflow-hidden shadow-lg border border-surface-container">
<img alt="Mapa" class="w-full h-full object-cover grayscale brightness-95" data-location="Island Map" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBk2DJPuV9gI-x9py77FpSjebhQWP2oTodviSuin7t1AdT2is_UNy1_S1Dh5m3b2yus8XLJV29sKP_fL4tBhAUQRE1KUynz8TzM22IlKI2d8OSNXYGafW1h4lMxGwVT9ctm_QKCsz5O8a0tO4Kftf5z8-4s-Az-AkxwLIDSsDkXcxeJCvP6aS6OgG4Zkx0rLdeubNIkrJDCSg7PlridtRtt0wfHkwIn5xzjW0Eg55yL2A4cth7O-SMi63jLQXe4KmCjaFvcNZ6Qy_o"/>
<!-- Map UI Elements -->
<div class="absolute top-md left-md flex flex-col gap-sm">
<button class="w-12 h-12 bg-white rounded-lg shadow-lg flex items-center justify-center text-primary hover:bg-surface-container-low transition-colors">
<span class="material-symbols-outlined">add</span>
</button>
<button class="w-12 h-12 bg-white rounded-lg shadow-lg flex items-center justify-center text-primary hover:bg-surface-container-low transition-colors">
<span class="material-symbols-outlined">remove</span>
</button>
</div>
<div class="absolute bottom-md right-md">
<button class="bg-primary text-on-primary px-lg py-sm rounded-full shadow-lg flex items-center gap-sm font-label-lg hover:scale-95 transition-transform">
<span class="material-symbols-outlined">my_location</span> Localização Atual
                    </button>
</div>
<!-- Custom Map Markers Overlay -->
<div class="absolute inset-0 pointer-events-none">
<div class="absolute top-1/3 left-1/4 pointer-events-auto">
<div class="flex flex-col items-center">
<div class="bg-primary text-on-primary px-sm py-xs rounded-lg shadow-xl mb-xs font-label-lg">Restaurante Maré</div>
<span class="material-symbols-outlined text-primary text-4xl" style="font-variation-settings: 'FILL' 1;">location_on</span>
</div>
</div>
<div class="absolute bottom-1/4 right-1/3 pointer-events-auto">
<div class="flex flex-col items-center">
<div class="bg-secondary text-on-secondary px-sm py-xs rounded-lg shadow-xl mb-xs font-label-lg">Praia Secreta</div>
<span class="material-symbols-outlined text-secondary text-4xl" style="font-variation-settings: 'FILL' 1;">location_on</span>
</div>
</div>
</div>
</div>
</section>
</main>
<!-- Navigation Shells -->
<!-- Mobile Bottom NavBar -->
<nav class="md:hidden fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-gutter py-sm bg-surface-container-lowest dark:bg-surface-container-highest shadow-[0_-4px_16px_rgba(0,23,54,0.08)] rounded-t-xl">
<div class="flex flex-col items-center justify-center bg-secondary-container dark:bg-primary-container text-on-secondary-container dark:text-primary-fixed-dim rounded-full px-5 py-1 scale-90 transition-all duration-200">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-label-sm text-label-sm">Início</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline-variant px-5 py-1 hover:bg-surface-variant dark:hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined" data-icon="directions_car">directions_car</span>
<span class="font-label-sm text-label-sm">Viagens</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline-variant px-5 py-1 hover:bg-surface-variant dark:hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined" data-icon="calendar_today">calendar_today</span>
<span class="font-label-sm text-label-sm">Reservas</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline-variant px-5 py-1 hover:bg-surface-variant dark:hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label-sm text-label-sm">Perfil</span>
</div>
</nav>
<!-- Desktop Navigation Cluster (In TopAppBar) -->
<div class="hidden md:flex fixed top-0 left-1/2 -translate-x-1/2 h-14 items-center z-[70] gap-lg">
<button class="text-secondary dark:text-secondary-fixed font-label-lg border-b-2 border-secondary h-full flex items-center px-md">Início</button>
<button class="text-on-surface-variant dark:text-outline-variant font-label-lg h-full flex items-center px-md hover:text-primary transition-colors">Viagens</button>
<button class="text-on-surface-variant dark:text-outline-variant font-label-lg h-full flex items-center px-md hover:text-primary transition-colors">Reservas</button>
<button class="text-on-surface-variant dark:text-outline-variant font-label-lg h-full flex items-center px-md hover:text-primary transition-colors">Perfil</button>
</div>
<!-- Floating Action Button -->
<button class="fixed bottom-24 right-margin-mobile md:bottom-md z-50 w-14 h-14 bg-secondary-container text-on-secondary-container rounded-xl shadow-xl flex items-center justify-center hover:scale-105 active:scale-95 transition-transform">
<span class="material-symbols-outlined text-3xl">add_location_alt</span>
</button>
</body></html>