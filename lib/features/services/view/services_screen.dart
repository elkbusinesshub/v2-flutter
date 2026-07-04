import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ── design tokens ──────────────────────────────────────────────────────────
const _dark9 = Color(0xFF0C241D);
const _dark7 = Color(0xFF1A4A3C);
const _ink9  = Color(0xFF16271F);
const _ink4  = Color(0xFF8C9890);
const _bg    = Color(0xFFF1F4EE);
const _line  = Color(0xFFE6EBE5);

// ── SVG gradient defs (shared) ────────────────────────────────────────────
const _defs =
    '<defs>'
    '<linearGradient id="gTealI" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#2FB29C"/>'
    '<stop offset="1" stop-color="#137A6D"/>'
    '</linearGradient>'
    '<linearGradient id="gYel" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#FBDA4E"/>'
    '<stop offset="1" stop-color="#E9B71C"/>'
    '</linearGradient>'
    '<linearGradient id="gS" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#D6DEE3"/>'
    '<stop offset="1" stop-color="#9AA7AF"/>'
    '</linearGradient>'
    '<linearGradient id="gB" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#7FD3F2"/>'
    '<stop offset="1" stop-color="#3FA8D6"/>'
    '</linearGradient>'
    '<linearGradient id="gWood" x1="0" y1="0" x2="1" y2="1">'
    '<stop offset="0" stop-color="#DBA262"/>'
    '<stop offset="1" stop-color="#9C6A2E"/>'
    '</linearGradient>'
    '<linearGradient id="gPink" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#EE7CA0"/>'
    '<stop offset="1" stop-color="#D14B77"/>'
    '</linearGradient>'
    '</defs>';

String _svg(String body) =>
    '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs$body</svg>';

// ── SVG illustration strings ──────────────────────────────────────────────
final _svgHome = _svg(
  '<path d="M8 23 24 10 40 23 Z" fill="#E2705C"/>'
  '<rect x="12" y="22" width="24" height="16" rx="1.5" fill="#F3E9D9"/>'
  '<rect x="20" y="28" width="8" height="10" rx="1" fill="#C98A5A"/>'
  '<rect x="15" y="26" width="5" height="5" rx="1" fill="url(#gB)"/>'
  '<rect x="28" y="26" width="5" height="5" rx="1" fill="url(#gB)"/>'
  '<rect x="29" y="13" width="4" height="6" fill="#C95F4D"/>',
);

final _svgSparkle = _svg(
  '<path d="M18 12l2.2 6.6L27 21l-6.8 2.4L18 30l-2.2-6.6L9 21l6.8-2.4L18 12Z" fill="url(#gYel)"/>'
  '<path d="M33 23l1.5 4.2 4.5 1.5-4.5 1.5L33 39l-1.5-4.8-4.5-1.5 4.5-1.5L33 23Z" fill="url(#gTealI)"/>'
  '<circle cx="14" cy="34" r="2" fill="#F6CE19"/>',
);

final _svgSofa = _svg(
  '<rect x="9" y="23" width="30" height="11" rx="4" fill="url(#gTealI)"/>'
  '<path d="M11 23v-3a4 4 0 0 1 4-4h18a4 4 0 0 1 4 4v3" fill="#0F6E60"/>'
  '<rect x="14" y="21" width="20" height="7" rx="3" fill="#E7F6F2"/>'
  '<rect x="7" y="21" width="6" height="13" rx="3" fill="#137A6D"/>'
  '<rect x="35" y="21" width="6" height="13" rx="3" fill="#137A6D"/>'
  '<rect x="12" y="34" width="3" height="5" rx="1" fill="#0F6E60"/>'
  '<rect x="33" y="34" width="3" height="5" rx="1" fill="#0F6E60"/>',
);

final _svgBasket = _svg(
  '<ellipse cx="24" cy="22" rx="11" ry="5" fill="#fff"/>'
  '<circle cx="18" cy="20" r="4" fill="#E7F6F2"/>'
  '<circle cx="27" cy="19" r="5" fill="#fff"/>'
  '<circle cx="31" cy="22" r="3.5" fill="#D2EFE8"/>'
  '<path d="M13 24 h22 l-2 13 a3 3 0 0 1-3 2.6 H18 a3 3 0 0 1-3-2.6 Z" fill="url(#gWood)"/>'
  '<path d="M16 27 l1 11M22 27 v11M28 27 l1 11" stroke="#8C5E26" stroke-width="1.3" opacity=".6"/>',
);

final _svgIron = _svg(
  '<path d="M9 31 Q9 23 20 22 L36 22 Q39 22 39 25 L39 31 Z" fill="url(#gTealI)"/>'
  '<rect x="9" y="31" width="30" height="3.4" rx="1.7" fill="#0F6E60"/>'
  '<path d="M28 22 v-4 a3.5 3.5 0 0 1 7 0" stroke="#137A6D" stroke-width="3" fill="none"/>'
  '<circle cx="15" cy="28" r="1.6" fill="#F6CE19"/>'
  '<path d="M14 15c1 1 1 2.4 0 3.4M19 14c1 1 1 2.4 0 3.4" stroke="url(#gB)" stroke-width="1.8" stroke-linecap="round"/>',
);

final _svgAc = _svg(
  '<rect x="6" y="15" width="36" height="14" rx="5" fill="url(#gS)"/>'
  '<rect x="6" y="15" width="36" height="6" rx="5" fill="#fff" opacity=".55"/>'
  '<rect x="9" y="25" width="30" height="2.6" rx="1.3" fill="url(#gTealI)"/>'
  '<circle cx="37" cy="18.5" r="1.5" fill="#3FA8D6"/>'
  '<path d="M11 33c1.6-2.2 3.2-2.2 4.8 0M21.6 33c1.6-2.2 3.2-2.2 4.8 0M32.2 33c1.6-2.2 3.2-2.2 4.8 0" stroke="url(#gB)" stroke-width="2" fill="none" stroke-linecap="round"/>',
);

final _svgWrench = _svg(
  '<path d="M31 11a8 8 0 0 0-10 10.4L9 33.5a3.4 3.4 0 1 0 4.8 4.8l12.1-12.1A8 8 0 0 0 37 16l-4.3 4.3-4-.6-.6-4L32.5 11Z" fill="url(#gS)"/>'
  '<path d="M30 28l9 9a2.9 2.9 0 0 1-4 4l-9-9" fill="#137A6D"/>'
  '<circle cx="13" cy="34.5" r="1.7" fill="#fff"/>',
);

final _svgGear = _svg(
  '<g fill="url(#gS)">'
  '<rect x="21.5" y="7" width="5" height="7" rx="1.5"/>'
  '<rect x="21.5" y="34" width="5" height="7" rx="1.5"/>'
  '<rect x="7" y="21.5" width="7" height="5" rx="1.5"/>'
  '<rect x="34" y="21.5" width="7" height="5" rx="1.5"/>'
  '<rect x="12" y="12" width="5" height="7" rx="1.5" transform="rotate(45 14.5 15.5)"/>'
  '<rect x="31" y="29" width="5" height="7" rx="1.5" transform="rotate(45 33.5 32.5)"/>'
  '<rect x="31" y="12" width="5" height="7" rx="1.5" transform="rotate(-45 33.5 15.5)"/>'
  '<rect x="12" y="29" width="5" height="7" rx="1.5" transform="rotate(-45 14.5 32.5)"/>'
  '</g>'
  '<circle cx="24" cy="24" r="11" fill="url(#gS)"/>'
  '<circle cx="24" cy="24" r="5" fill="#137A6D"/>',
);

final _svgPipe = _svg(
  '<path d="M16 12v8a8 8 0 0 0 16 0v-2" stroke="#AEBAC2" stroke-width="6" fill="none" stroke-linecap="round"/>'
  '<rect x="12" y="9" width="8" height="5" rx="1.5" fill="#7E8C95"/>'
  '<rect x="28" y="15" width="8" height="5" rx="1.5" fill="#7E8C95"/>'
  '<path d="M24 30c1.7 2.2 3 4 3 5.6a3 3 0 0 1-6 0c0-1.6 1.3-3.4 3-5.6Z" fill="url(#gB)"/>',
);

final _svgBolt = _svg(
  '<path d="M27 6 15 26h8l-3 16 15-22h-9l3-12Z" fill="url(#gYel)"/>',
);

final _svgRoller = _svg(
  '<rect x="13" y="12" width="21" height="9" rx="3.5" fill="url(#gTealI)"/>'
  '<rect x="13" y="11.5" width="21" height="3" rx="1.5" fill="#fff" opacity=".4"/>'
  '<path d="M23.5 21 v3 h-6 v5" stroke="#5C6A60" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
  '<rect x="14.5" y="29" width="6" height="11" rx="3" fill="url(#gWood)"/>',
);

// taxi & rides
final _svgTaxiCab = _svg(
  '<rect x="20" y="11" width="9" height="5" rx="1.3" fill="#15241F"/>'
  '<path d="M9 31c0-1 .5-2.4 1.3-3.3l3.2-6.3c.8-1.6 2.3-2.4 4-2.4h12.9c1.7 0 3.2.8 4 2.4l3.2 6.3c.8.9 1.3 2.3 1.3 3.3v6c0 1.1-.9 2-2 2H11c-1.1 0-2-.9-2-2v-6Z" fill="url(#gYel)"/>'
  '<path d="M14.4 21.6 12.6 26h22.8l-1.8-4.4c-.5-1-1.3-1.6-2.4-1.6H16.8c-1.1 0-1.9.6-2.4 1.6Z" fill="#2C3A44"/>'
  '<rect x="9" y="29" width="30" height="3" fill="#15241F"/>'
  '<rect x="9" y="29" width="5" height="3" fill="#F6CE19"/>'
  '<rect x="19" y="29" width="5" height="3" fill="#F6CE19"/>'
  '<rect x="29" y="29" width="5" height="3" fill="#F6CE19"/>'
  '<circle cx="16" cy="37" r="3.4" fill="#15241F"/>'
  '<circle cx="32" cy="37" r="3.4" fill="#15241F"/>',
);

final _svgAuto = _svg(
  '<path d="M12 20c0-4 3-6.5 8-6.5h12c2.6 0 4 1.8 4 4.5v2Z" fill="url(#gYel)"/>'
  '<path d="M12 20h24v12a2 2 0 0 1-2 2H14a2 2 0 0 1-2-2Z" fill="url(#gTealI)"/>'
  '<rect x="15" y="22" width="8" height="7" rx="1.5" fill="#DFF3EF"/>'
  '<rect x="27" y="22" width="6" height="7" rx="1.5" fill="#0F6E60"/>'
  '<circle cx="16" cy="36" r="3.2" fill="#15241F"/>'
  '<circle cx="32" cy="36" r="3.2" fill="#15241F"/>',
);

final _svgSedan = _svg(
  '<path d="M10 27c0-.8.4-1.9 1-2.6l3-5c.8-1.3 2-2 3.5-2h13c1.5 0 2.7.7 3.5 2l3 5c.6.7 1 1.8 1 2.6v6c0 1.1-.9 2-2 2H12c-1.1 0-2-.9-2-2v-6Z" fill="url(#gYel)"/>'
  '<path d="M15.5 19.5 14 24h20l-1.5-4.5c-.4-1-1.2-1.5-2.2-1.5H17.7c-1 0-1.8.5-2.2 1.5Z" fill="#2C3A44"/>'
  '<circle cx="16" cy="35" r="3.2" fill="#15241F"/>'
  '<circle cx="32" cy="35" r="3.2" fill="#15241F"/>'
  '<ellipse cx="12.5" cy="28.5" rx="1.5" ry="1.8" fill="#FCEFB0"/>'
  '<ellipse cx="35.5" cy="28.5" rx="1.5" ry="1.8" fill="#FCEFB0"/>',
);

final _svgSuv = _svg(
  '<path d="M9 21c0-1.1.9-2 2-2h1l4-6h16l4 6h2c1.1 0 2 .9 2 2v8c0 1.1-.9 2-2 2H11c-1.1 0-2-.9-2-2v-8Z" fill="url(#gTealI)"/>'
  '<path d="M16.5 15h6v4h-8.6Z" fill="#2C3A44"/>'
  '<path d="M24.5 15h5.3l2.7 4h-8Z" fill="#2C3A44"/>'
  '<circle cx="16" cy="33" r="3.4" fill="#15241F"/>'
  '<circle cx="32" cy="33" r="3.4" fill="#15241F"/>'
  '<ellipse cx="11.5" cy="23.5" rx="1.4" ry="1.7" fill="#FCEFB0"/>',
);

final _svgLux = _svg(
  '<path d="M10 27c0-.8.4-1.9 1-2.6l3-5c.8-1.3 2-2 3.5-2h13c1.5 0 2.7.7 3.5 2l3 5c.6.7 1 1.8 1 2.6v6c0 1.1-.9 2-2 2H12c-1.1 0-2-.9-2-2v-6Z" fill="url(#gS)"/>'
  '<path d="M15.5 19.5 14 24h20l-1.5-4.5c-.4-1-1.2-1.5-2.2-1.5H17.7c-1 0-1.8.5-2.2 1.5Z" fill="#2C3A44"/>'
  '<circle cx="16" cy="35" r="3.2" fill="#15241F"/>'
  '<circle cx="32" cy="35" r="3.2" fill="#15241F"/>'
  '<path d="M24 6l1.3 2.8 3 .4-2.2 2 .6 3L24 12.7l-2.7 1.5.6-3-2.2-2 3-.4L24 6Z" fill="url(#gYel)"/>',
);

final _svgVan = _svg(
  '<path d="M9 18c0-1.7 1.3-3 3-3h17c5.5 0 10 4.5 10 10v6c0 1.1-.9 2-2 2H11c-1.1 0-2-.9-2-2V18Z" fill="url(#gB)"/>'
  '<rect x="12" y="18" width="7" height="6" rx="1.5" fill="#fff" opacity=".85"/>'
  '<rect x="22" y="18" width="7" height="6" rx="1.5" fill="#fff" opacity=".85"/>'
  '<circle cx="16" cy="34" r="3.2" fill="#15241F"/>'
  '<circle cx="32" cy="34" r="3.2" fill="#15241F"/>',
);

// stay
final _svgBldg = _svg(
  '<rect x="11" y="13" width="26" height="27" rx="2" fill="url(#gTealI)"/>'
  '<rect x="15" y="17" width="5" height="5" rx="1" fill="#E7F6F2"/>'
  '<rect x="21.5" y="17" width="5" height="5" rx="1" fill="#E7F6F2"/>'
  '<rect x="28" y="17" width="5" height="5" rx="1" fill="#E7F6F2"/>'
  '<rect x="15" y="25" width="5" height="5" rx="1" fill="#E7F6F2"/>'
  '<rect x="28" y="25" width="5" height="5" rx="1" fill="#E7F6F2"/>'
  '<rect x="21.5" y="31" width="5" height="9" rx="1" fill="url(#gYel)"/>'
  '<path d="M9 13 24 6l15 7Z" fill="#0F6E60"/>',
);

final _svgBunk = _svg(
  '<rect x="10" y="11" width="3.2" height="28" rx="1.6" fill="url(#gWood)"/>'
  '<rect x="34.8" y="11" width="3.2" height="28" rx="1.6" fill="url(#gWood)"/>'
  '<rect x="12" y="17" width="24" height="4.4" rx="2.2" fill="url(#gTealI)"/>'
  '<rect x="12" y="29" width="24" height="4.4" rx="2.2" fill="url(#gTealI)"/>'
  '<circle cx="17.5" cy="14.6" r="2.5" fill="url(#gYel)"/>'
  '<circle cx="17.5" cy="26.6" r="2.5" fill="url(#gYel)"/>',
);

final _svgBunkPink = _svg(
  '<rect x="10" y="11" width="3.2" height="28" rx="1.6" fill="url(#gWood)"/>'
  '<rect x="34.8" y="11" width="3.2" height="28" rx="1.6" fill="url(#gWood)"/>'
  '<rect x="12" y="17" width="24" height="4.4" rx="2.2" fill="url(#gPink)"/>'
  '<rect x="12" y="29" width="24" height="4.4" rx="2.2" fill="url(#gPink)"/>'
  '<circle cx="17.5" cy="14.6" r="2.5" fill="url(#gYel)"/>'
  '<circle cx="17.5" cy="26.6" r="2.5" fill="url(#gYel)"/>',
);

// porter
final _svgBike = _svg(
  '<circle cx="13" cy="33" r="5.2" stroke="#15241F" stroke-width="2.4" fill="none"/>'
  '<circle cx="35" cy="33" r="5.2" stroke="#15241F" stroke-width="2.4" fill="none"/>'
  '<path d="M13 33 19 22h9l7 11" stroke="url(#gTealI)" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
  '<path d="M19 22h-4.5" stroke="#15241F" stroke-width="2.4" stroke-linecap="round"/>'
  '<rect x="25" y="11" width="11" height="10" rx="2" fill="url(#gYel)"/>'
  '<path d="M25 16h11" stroke="#B98A12" stroke-width="1.4"/>',
);

final _svgTruckS = _svg(
  '<rect x="17" y="13" width="22" height="19" rx="1.5" fill="url(#gYel)"/>'
  '<path d="M8 21c0-.6.4-1 1-1h8v12H9c-.6 0-1-.4-1-1v-10Z" fill="url(#gTealI)"/>'
  '<rect x="10" y="22.5" width="5.5" height="4.5" rx="1" fill="#DFF3EF"/>'
  '<rect x="8" y="30" width="31" height="3" fill="#15241F"/>'
  '<circle cx="15" cy="36" r="3.2" fill="#15241F"/>'
  '<circle cx="31" cy="36" r="3.2" fill="#15241F"/>',
);

final _svgBox = _svg(
  '<path d="M10 18 24 12 38 18 24 24Z" fill="url(#gWood)"/>'
  '<path d="M10 18v14l14 6V24Z" fill="#C98A5A"/>'
  '<path d="M38 18v14l-14 6V24Z" fill="#A9772A"/>'
  '<path d="M17 15l14 6" stroke="#fff" stroke-width="1.6" opacity=".65"/>',
);

// cleaning extras
final _svgPot = _svg(
  '<rect x="12" y="22" width="24" height="12" rx="3" fill="url(#gS)"/>'
  '<path d="M8 25h4M36 25h4" stroke="#7E8C95" stroke-width="3" stroke-linecap="round"/>'
  '<rect x="10" y="19" width="28" height="4" rx="2" fill="#7E8C95"/>'
  '<path d="M19 11c1 1.4 1 2.8 0 4.2M25 10c1 1.4 1 2.8 0 4.2M31 11c1 1.4 1 2.8 0 4.2" stroke="url(#gTealI)" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
);

final _svgShower = _svg(
  '<path d="M13 39V14a5 5 0 0 1 10 0v1" stroke="url(#gS)" stroke-width="3.6" fill="none" stroke-linecap="round"/>'
  '<path d="M23 15h9a4 4 0 0 1 4 4v1H19v-1a4 4 0 0 1 4-4Z" fill="url(#gB)"/>'
  '<path d="M22 25v3M27 24v3M32 25v3M36 24v3M24 32v3M29 31v3M34 32v3" stroke="url(#gB)" stroke-width="2" stroke-linecap="round"/>',
);

final _svgRug = _svg(
  '<rect x="10" y="14" width="28" height="21" rx="2.5" fill="url(#gTealI)"/>'
  '<rect x="14" y="18" width="20" height="13" rx="1.5" fill="none" stroke="#E7F6F2" stroke-width="1.8"/>'
  '<circle cx="24" cy="24.5" r="2.6" fill="url(#gYel)"/>'
  '<path d="M13 35v3.5M18.5 35v3.5M24 35v3.5M29.5 35v3.5M35 35v3.5" stroke="#0F6E60" stroke-width="1.6" stroke-linecap="round"/>',
);

final _svgTank = _svg(
  '<path d="M12 15v16c0 2.2 5.4 4 12 4s12-1.8 12-4V15" fill="url(#gB)"/>'
  '<ellipse cx="24" cy="15" rx="12" ry="4.5" fill="#BFE9F7"/>'
  '<path d="M24 22c1.6 2.1 2.8 3.8 2.8 5.3a2.8 2.8 0 0 1-5.6 0c0-1.5 1.2-3.2 2.8-5.3Z" fill="#fff"/>',
);

// repair extras
final _svgHammer = _svg(
  '<rect x="11" y="9" width="17" height="8" rx="2.5" transform="rotate(38 19.5 13)" fill="url(#gS)"/>'
  '<rect x="19.5" y="19" width="6.5" height="21" rx="3" transform="rotate(-52 22.75 29.5)" fill="url(#gWood)"/>',
);

// ── local data: 6 modules matching the home screen categories ─────────────
class _Item {
  const _Item(this.name, this.icon, this.price);
  final String name;
  final String icon; // full SVG string
  final int price;
}

class _Module {
  const _Module({
    required this.id,
    required this.title,
    required this.grad,
    required this.icon,
    required this.items,
  });
  final String id, title;
  final String icon; // section badge SVG
  final LinearGradient grad;
  final List<_Item> items;
}

final _modules = <_Module>[
  _Module(
    id: 'taxi',
    title: 'Taxi & Rides',
    grad: const LinearGradient(
        colors: [Color(0xFFF6CE19), Color(0xFFE0A012)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgTaxiCab,
    items: [
      _Item('Economy Taxi', _svgTaxiCab, 12),
      _Item('Premium Taxi', _svgSedan, 25),
      _Item('Auto', _svgAuto, 8),
      _Item('XL Van', _svgVan, 30),
    ],
  ),
  _Module(
    id: 'elkstay',
    title: 'ELK Stay',
    grad: const LinearGradient(
        colors: [Color(0xFF8E7CEE), Color(0xFF5B4BC9)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgBldg,
    items: [
      _Item('PG Stay', _svgBldg, 220),
      _Item("Men's Hostel", _svgBunk, 180),
      _Item("Women's Hostel", _svgBunkPink, 190),
      _Item('Homestay', _svgHome, 260),
    ],
  ),
  _Module(
    id: 'cleaning',
    title: 'Cleaning',
    grad: const LinearGradient(
        colors: [Color(0xFF2FB29C), Color(0xFF137A6D)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgSparkle,
    items: [
      _Item('Home Cleaning', _svgHome, 60),
      _Item('Deep Cleaning', _svgSparkle, 72),
      _Item('Sofa & Upholstery', _svgSofa, 90),
      _Item('Kitchen Cleaning', _svgPot, 45),
      _Item('Bathroom Cleaning', _svgShower, 35),
      _Item('Carpet & Rug', _svgRug, 55),
      _Item('Laundry & Iron', _svgIron, 12),
      _Item('Wash & Fold', _svgBasket, 25),
      _Item('Water Tank', _svgTank, 80),
    ],
  ),
  _Module(
    id: 'car_rental',
    title: 'Car Rental',
    grad: const LinearGradient(
        colors: [Color(0xFFE2972E), Color(0xFFC06D12)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgSedan,
    items: [
      _Item('Sedan', _svgSedan, 89),
      _Item('SUV', _svgSuv, 120),
      _Item('Luxury', _svgLux, 250),
      _Item('Van', _svgVan, 140),
    ],
  ),
  _Module(
    id: 'repair',
    title: 'Repair',
    grad: const LinearGradient(
        colors: [Color(0xFF5FCEDE), Color(0xFF2BA0B8)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgWrench,
    items: [
      _Item('AC & Cooling', _svgAc, 40),
      _Item('Plumbing', _svgPipe, 45),
      _Item('Electrical', _svgBolt, 50),
      _Item('Carpentry', _svgHammer, 65),
      _Item('Painting', _svgRoller, 130),
      _Item('Handyman', _svgGear, 35),
    ],
  ),
  _Module(
    id: 'porter',
    title: 'Porter & Movers',
    grad: const LinearGradient(
        colors: [Color(0xFFEE7CA0), Color(0xFFD14B77)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    icon: _svgTruckS,
    items: [
      _Item('Bike Delivery', _svgBike, 15),
      _Item('Mini Truck', _svgTruckS, 60),
      _Item('House Shifting', _svgBox, 150),
      _Item('Movers & Packers', _svgBox, 200),
    ],
  ),
];

// ── screen ────────────────────────────────────────────────────────────────
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, this.onCategoryTap});

  /// Called with the module id ('taxi', 'elkstay', 'cleaning', 'car_rental',
  /// 'repair', 'porter') when a section or item is tapped.
  final ValueChanged<String>? onCategoryTap;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modules = _q.isEmpty
        ? _modules
        : _modules
            .map((m) => _Module(
                  id: m.id,
                  title: m.title,
                  grad: m.grad,
                  icon: m.icon,
                  items: m.title.toLowerCase().contains(_q)
                      ? m.items
                      : m.items
                          .where((i) => i.name.toLowerCase().contains(_q))
                          .toList(),
                ))
            .where((m) => m.items.isNotEmpty)
            .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _Header(),
        _SearchBar(
          ctrl: _ctrl,
          hasQuery: _q.isNotEmpty,
          onChanged: (v) => setState(() => _q = v.toLowerCase().trim()),
          onClear: () {
            _ctrl.clear();
            setState(() => _q = '');
          },
        ),
        Expanded(
          child: modules.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No services match "${_ctrl.text}".\nTry "AC", "taxi" or "clean".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _ink4,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  itemCount: modules.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _SectionCard(
                    module: modules[i],
                    onTap: () => widget.onCategoryTap?.call(modules[i].id),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ── dark header ────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.6, -1),
          end: Alignment(-0.2, 1),
          colors: [_dark7, _dark9],
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, top + 8, 18, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 13),
        Text(
          'Services',
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        SvgPicture.asset('assets/icons/elk_logo.svg', height: 23),
      ]),
    );
  }
}

// ── search bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.ctrl,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController ctrl;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F142818), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: Color(0xFF0F6E60), size: 18),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              cursorColor: const Color(0xFF0F6E60),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _ink9,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: 'Search services… (e.g. AC, taxi)',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _ink4,
                ),
              ),
            ),
          ),
          if (hasQuery)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close_rounded, color: _ink4, size: 16),
            ),
        ]),
      ),
    );
  }
}

// ── section card (horizontal item rail) ────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.module, required this.onTap});

  final _Module module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x0F142818), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section header — opens the module
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: module.grad,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: SvgPicture.string(module.icon, width: 24, height: 24),
                ),
              ),
              const SizedBox(width: 11),
              Text(
                module.title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ink9,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, size: 22, color: _ink4),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        // Horizontally scrolling items
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: module.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _ItemCard(
              item: module.items[i],
              onTap: onTap,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── item card ──────────────────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});

  final _Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.fromLTRB(6, 11, 6, 9),
        decoration: BoxDecoration(
          color: _bg,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(item.icon, width: 42, height: 42),
            const SizedBox(height: 7),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _ink9,
                letterSpacing: -0.1,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'from AED ${item.price}',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: _ink4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
