<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Manrope:wght@600;700;800&amp;display=swap" rel="stylesheet"/>
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
      .custom-scrollbar::-webkit-scrollbar {
        width: 6px;
      }
      .custom-scrollbar::-webkit-scrollbar-track {
        background: transparent;
      }
      .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #e0e3e5;
        border-radius: 10px;
      }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
</head>
<body class="flex min-h-screen">
<!-- NavigationDrawer (Sidebar) -->
<aside class="hidden md:flex flex-col h-full w-80 bg-surface border-r border-outline-variant py-xl fixed left-0 top-0 z-40">
<div class="px-md mb-xl">
<h1 class="font-headline-md text-headline-md font-bold text-primary">Premium Mobility</h1>
</div>
<div class="flex flex-col px-md mb-lg">
<div class="flex items-center gap-md p-md bg-surface-container-low rounded-xl">
<div class="w-12 h-12 rounded-full bg-secondary-container flex items-center justify-center overflow-hidden">
<img alt="Avatar" class="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuC5B2j7iPJhUcDf5U2fxhXVTI0uMSmeQiNtfbI_OtQhjq07gDpdU54Kyv8WgEcC6OUX1JWx-q2czFYYkuwfhHfRF6aSElsWIiQqzwNaV-e6GbiWHnRuIo3pnjbeLp_JxAHMewis9MB5_WY7Otkf80IlV3KLgrejIeGTyG4G04bgPZGiMQqQegQgWgmnq_c2cY367ktoTv7QUWWvovMFRDJtkKCYNCbqgHZro3rqXZEodQz7zLIPeKlHQzA9BaiT1RRWhN1mmJKy1g4"/>
</div>
<div>
<p class="font-label-lg text-label-lg text-on-surface">Fleet Manager</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">Central Lisbon Fleet</p>
<span class="text-[10px] font-bold uppercase tracking-wider text-secondary px-2 py-0.5 bg-secondary-fixed rounded-full">Admin</span>
</div>
</div>
</div>
<nav class="flex-1 space-y-xs px-md overflow-y-auto custom-scrollbar">
<a class="flex items-center gap-md text-on-surface-variant hover:bg-surface-container-high mx-md my-xs px-md py-sm rounded-full transition-all" href="#">
<span class="material-symbols-outlined">dashboard</span>
<span class="font-label-lg text-label-lg">Home</span>
</a>
<a class="flex items-center gap-md bg-secondary-container text-on-secondary-container mx-md my-xs px-md py-sm rounded-full transition-transform duration-200 translate-x-1" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">analytics</span>
<span class="font-label-lg text-label-lg">Trips</span>
</a>
<a class="flex items-center gap-md text-on-surface-variant hover:bg-surface-container-high mx-md my-xs px-md py-sm rounded-full transition-all" href="#">
<span class="material-symbols-outlined">calendar_month</span>
<span class="font-label-lg text-label-lg">Bookings</span>
</a>
<a class="flex items-center gap-md text-on-surface-variant hover:bg-surface-container-high mx-md my-xs px-md py-sm rounded-full transition-all" href="#">
<span class="material-symbols-outlined">person</span>
<span class="font-label-lg text-label-lg">Profile</span>
</a>
<a class="flex items-center gap-md text-on-surface-variant hover:bg-surface-container-high mx-md my-xs px-md py-sm rounded-full transition-all" href="#">
<span class="material-symbols-outlined">settings</span>
<span class="font-label-lg text-label-lg">Settings</span>
</a>
</nav>
<div class="px-md mt-auto pt-lg">
<a class="flex items-center gap-md text-error hover:bg-error-container/10 mx-md my-xs px-md py-sm rounded-full transition-all" href="#">
<span class="material-symbols-outlined">logout</span>
<span class="font-label-lg text-label-lg">Sign Out</span>
</a>
</div>
</aside>
<!-- Main Content Canvas -->
<main class="flex-1 md:ml-80 pb-24 md:pb-lg">
<!-- TopAppBar -->
<header class="flex justify-between items-center px-margin-mobile h-14 w-full bg-surface sticky top-0 z-30">
<div class="flex items-center gap-sm">
<button class="md:hidden p-sm text-primary">
<span class="material-symbols-outlined">menu</span>
</button>
<h2 class="font-headline-md text-headline-md font-bold text-primary">Detailed Reports</h2>
</div>
<div class="flex items-center gap-md">
<button class="flex items-center justify-center w-10 h-10 rounded-full hover:bg-surface-container-low transition-colors">
<span class="material-symbols-outlined">notifications</span>
</button>
<div class="w-8 h-8 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-xs">
                    GP
                </div>
</div>
</header>
<div class="p-margin-mobile md:p-lg space-y-lg">
<!-- Filters Section -->
<section class="bg-surface-container-lowest p-md md:p-lg rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<div class="flex flex-col md:flex-row md:items-end gap-md">
<div class="flex-1 space-y-xs">
<label class="font-label-sm text-label-sm text-on-surface-variant px-xs">Date Range</label>
<div class="relative">
<span class="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-outline">calendar_today</span>
<input class="w-full pl-xl pr-md py-sm bg-surface-container-low border-2 border-transparent focus:border-secondary rounded-lg font-body-md text-body-md outline-none transition-all" type="text" value="01 Jan 2024 - 31 Jan 2024"/>
</div>
</div>
<div class="flex-1 space-y-xs">
<label class="font-label-sm text-label-sm text-on-surface-variant px-xs">Vehicle / Fleet</label>
<div class="relative">
<span class="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-outline">directions_car</span>
<select class="w-full pl-xl pr-md py-sm bg-surface-container-low border-2 border-transparent focus:border-secondary rounded-lg font-body-md text-body-md outline-none appearance-none transition-all">
<option>All Vehicles</option>
<option>Light Fleet</option>
<option>Heavy Fleet</option>
<option>Executive</option>
</select>
</div>
</div>
<button class="h-[56px] px-lg bg-secondary text-on-secondary rounded-lg font-label-lg text-label-lg flex items-center justify-center gap-sm active:scale-95 transition-transform">
<span class="material-symbols-outlined">file_download</span>
                        Export
                    </button>
</div>
</section>
<!-- Summary Bento Grid -->
<section class="grid grid-cols-2 md:grid-cols-5 gap-md">
<!-- Total Viagens -->
<div class="col-span-1 bg-surface-container-lowest p-md rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)] border-l-4 border-secondary">
<p class="font-label-sm text-label-sm text-on-surface-variant mb-xs">Total Trips</p>
<div class="flex items-end justify-between">
<h3 class="font-headline-md text-headline-md text-primary">1,284</h3>
<span class="text-[10px] text-secondary font-bold bg-secondary-fixed px-1.5 py-0.5 rounded">+12%</span>
</div>
</div>
<!-- Distância -->
<div class="col-span-1 bg-surface-container-lowest p-md rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<p class="font-label-sm text-label-sm text-on-surface-variant mb-xs">Total Distance</p>
<div class="flex items-end justify-between">
<h3 class="font-headline-md text-headline-md text-primary">14.2k <span class="text-label-sm font-normal">km</span></h3>
</div>
</div>
<!-- Tempo -->
<div class="col-span-1 bg-surface-container-lowest p-md rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<p class="font-label-sm text-label-sm text-on-surface-variant mb-xs">Time en Route</p>
<div class="flex items-end justify-between">
<h3 class="font-headline-md text-headline-md text-primary">842 <span class="text-label-sm font-normal">h</span></h3>
</div>
</div>
<!-- Custo -->
<div class="col-span-1 bg-surface-container-lowest p-md rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<p class="font-label-sm text-label-sm text-on-surface-variant mb-xs">Total Cost</p>
<div class="flex items-end justify-between">
<h3 class="font-headline-md text-headline-md text-primary">42.1k <span class="text-label-sm font-normal">€</span></h3>
</div>
</div>
<!-- Dívida -->
<div class="col-span-2 md:col-span-1 bg-error-container/10 border border-error/20 p-md rounded-xl shadow-[0_2px_8px_rgba(0,23,54,0.04)]">
<div class="flex flex-col h-full justify-between">
<div>
<p class="font-label-sm text-label-sm text-error mb-xs">Pending Debt</p>
<h3 class="font-headline-md text-headline-md text-error">1.4k <span class="text-label-sm font-normal">€</span></h3>
</div>
<div class="flex items-center justify-between mt-xs">
<p class="text-[10px] text-error opacity-70 uppercase font-bold">overdue invoices</p>
<span class="material-symbols-outlined text-error text-md">warning</span>
</div>
</div>
</div>
</section>
<!-- Main Data Visualization / Table Placeholder -->
<section class="bg-surface-container-lowest rounded-xl shadow-[0_4px_16px_rgba(0,23,54,0.06)] overflow-hidden">
<div class="p-lg border-b border-surface-variant flex justify-between items-center">
<h3 class="font-headline-sm text-headline-sm text-primary">Monthly Performance Analysis</h3>
<div class="flex gap-xs">
<button class="p-xs hover:bg-surface-container-high rounded transition-colors"><span class="material-symbols-outlined text-on-surface-variant">more_vert</span></button>
</div>
</div>
<div class="p-lg space-y-lg">
<!-- High-end Graphic Placeholder -->
<div class="aspect-[21/9] w-full bg-surface-container-low rounded-lg relative overflow-hidden flex flex-col items-center justify-center p-xl">
<img class="absolute inset-0 w-full h-full object-cover opacity-80" data-alt="A clean, minimalist vector line chart showing fleet performance metrics. The chart features a primary deep blue line and a secondary soft light blue line flowing across a grid of subtle gray lines. The background is a crisp off-white light-mode surface. The overall aesthetic is professional, corporate, and data-driven with high legibility and plenty of white space." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCq4PqypmAlrt1YBF8Za0sW0OsxPFAKIS_RavqmXpFiv1oWYj4SdyFi_xGtHXfyV9tOzCF-bd0v-ErF3CCV8G7dTrNYvZDAlxY5E68k7_ax4gGjyOgfYcWy0xmMTp9Hs6XbQwxRsvTZFZnetHi1YmMX5jkVDzQJlUtIuoSdUrIuwr9sU4MqO7WOHwrKzC7ze66SFTllprJtS5AKQudGtB-TNYiNeFymzQBxzMr-L4rNJcGFYstmOlN6k0imS5C4qr2PHe1ga4G7zJc"/>
<div class="relative z-10 text-center space-y-md">
<span class="material-symbols-outlined text-xxl text-primary-container opacity-40">query_stats</span>
<p class="font-body-md text-body-md text-on-surface-variant max-w-md">Detailed visualization of cost trends and mileage processed for the selected period.</p>
</div>
</div>
<!-- Asymmetric Details Grid -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-lg">
<div class="md:col-span-2 space-y-md">
<h4 class="font-label-lg text-label-lg text-primary uppercase tracking-widest">LATEST ACTIVITIES</h4>
<div class="space-y-sm">
<div class="flex items-center justify-between p-md bg-surface-container-lowest border border-surface-variant/50 rounded-xl hover:shadow-md transition-shadow">
<div class="flex items-center gap-md">
<div class="w-10 h-10 rounded-lg bg-surface-container-high flex items-center justify-center">
<span class="material-symbols-outlined text-secondary">local_shipping</span>
</div>
<div>
<p class="font-label-lg text-label-lg">Regional Delivery Porto</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">VTR-402 • 14:20h</p>
</div>
</div>
<span class="font-label-lg text-label-lg text-primary">84.20 €</span>
</div>
<div class="flex items-center justify-between p-md bg-surface-container-lowest border border-surface-variant/50 rounded-xl hover:shadow-md transition-shadow">
<div class="flex items-center gap-md">
<div class="w-10 h-10 rounded-lg bg-surface-container-high flex items-center justify-center">
<span class="material-symbols-outlined text-secondary">commute</span>
</div>
<div>
<p class="font-label-lg text-label-lg">Executive Transfer Lisbon</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">VTR-108 • 11:45h</p>
</div>
</div>
<span class="font-label-lg text-label-lg text-primary">125.00 €</span>
</div>
</div>
</div>
<div class="bg-primary-container p-lg rounded-xl text-on-primary flex flex-col justify-between">
<div>
<h4 class="font-label-lg text-label-lg text-primary-fixed mb-md uppercase tracking-widest">FLEET EFFICIENCY</h4>
<div class="relative w-32 h-32 mx-auto mb-md">
<svg class="w-full h-full transform -rotate-90" viewbox="0 0 36 36">
<path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="#264778" stroke-dasharray="100, 100" stroke-width="3"></path>
<path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="#a9c7ff" stroke-dasharray="85, 100" stroke-width="3"></path>
</svg>
<div class="absolute inset-0 flex flex-col items-center justify-center">
<span class="text-headline-sm font-bold">85%</span>
<span class="text-[8px] uppercase tracking-tighter opacity-70">OPTIMIZED</span>
</div>
</div>
</div>
<p class="text-label-sm text-on-primary-container">Your fleet is operating 15% above the industry average this quarter.</p>
</div>
</div>
</div>
</section>
</div>
</main>
<!-- BottomNavBar (Mobile Only) -->
<nav class="md:hidden fixed bottom-0 left-0 right-0 bg-surface border-t border-outline-variant flex justify-around items-center h-16 z-40 px-md">
<a class="flex flex-col items-center gap-xs text-secondary" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">dashboard</span>
<span class="text-[10px] font-bold">Home</span>
</a>
<a class="flex flex-col items-center gap-xs text-on-surface-variant" href="#">
<span class="material-symbols-outlined">analytics</span>
<span class="text-[10px] font-bold">Trips</span>
</a>
<a class="flex flex-col items-center gap-xs text-on-surface-variant" href="#">
<span class="material-symbols-outlined">calendar_month</span>
<span class="text-[10px] font-bold">Bookings</span>
</a>
<a class="flex flex-col items-center gap-xs text-on-surface-variant" href="#">
<span class="material-symbols-outlined">person</span>
<span class="text-[10px] font-bold">Profile</span>
</a>
</nav>
</body></html>