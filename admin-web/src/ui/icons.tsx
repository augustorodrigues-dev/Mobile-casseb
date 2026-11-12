import type { SVGProps } from 'react';
type Props=SVGProps<SVGSVGElement>&{size?:number};
const paths={
  Compass:<><circle cx="12" cy="12" r="9"/><path d="m16 8-2.5 5.5L8 16l2.5-5.5Z"/></>,
  X:<path d="m6 6 12 12M6 18 18 6"/>,
  Download:<><path d="M12 3v12m-4-4 4 4 4-4M4 16v5h16v-5"/></>,
  Printer:<><path d="M6 8V3h12v5M6 17H3V9h18v8h-3M6 14h12v7H6z"/><path d="M17 11h1"/></>,
  ArrowUpRight:<path d="M6 18 18 6M6 6h12v12"/>,
  LayoutDashboard:<><path d="M3 3h8v8H3zm12 0h6v5h-6zM3 15h8v6H3zm12-3h6v9h-6z"/></>,
  LogOut:<path d="M10 3H3v18h7m-2-9h13m-4-4 4 4-4 4"/>,
  Plus:<path d="M12 4v16M4 12h16"/>,
  QrCode:<><path d="M3 3h6v6H3zm12 0h6v6h-6zM3 15h6v6H3zm12 0h3v3h3v3h-6zM12 3v2m0 5v3h-2m-7-1h4m5 5v4m9-9h-4"/></>,
  MapPin:<><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z"/><circle cx="12" cy="10" r="2"/></>,
  Pencil:<><path d="m15 4 5 5M3 21l5-1L21 7l-5-5L3 15Z"/></>,
  Search:<><circle cx="10" cy="10" r="7"/><path d="m15 15 6 6"/></>,
  Radio:<><circle cx="12" cy="12" r="2"/><path d="M7 7a7 7 0 0 0 0 10m10-10a7 7 0 0 1 0 10M4 4a11 11 0 0 0 0 16M20 4a11 11 0 0 1 0 16"/></>,
  Sprout:<><path d="M12 21V10C12 4 17 3 21 3c0 6-3 9-9 9M12 16C5 16 3 12 3 7c6 0 9 3 9 9"/></>,
  Users:<><circle cx="9" cy="7" r="4"/><path d="M2 21v-2a7 7 0 0 1 14 0v2M17 4a4 4 0 0 1 0 8m2 3a6 6 0 0 1 3 6"/></>,
  Store:<path d="M3 9h18l-2-6H5ZM4 9v12h16V9M9 21v-8h6v8M8 3 7 9m9-6 1 6"/>,
  CirclePause:<><circle cx="12" cy="12" r="9"/><path d="M9 8v8m6-8v8"/></>,
  CircleCheck:<><circle cx="12" cy="12" r="9"/><path d="m7 12 3 3 7-7"/></>,
};
function icon(name:keyof typeof paths){return function Icon({size=24,...props}:Props){return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true" {...props}>{paths[name]}</svg>;};}
export const Compass=icon('Compass'),X=icon('X'),Download=icon('Download'),Printer=icon('Printer'),ArrowUpRight=icon('ArrowUpRight'),LayoutDashboard=icon('LayoutDashboard'),LogOut=icon('LogOut'),Plus=icon('Plus'),QrCode=icon('QrCode'),MapPin=icon('MapPin'),Pencil=icon('Pencil'),Search=icon('Search'),Radio=icon('Radio'),Sprout=icon('Sprout'),Users=icon('Users'),Store=icon('Store'),CirclePause=icon('CirclePause'),CircleCheck=icon('CircleCheck');
