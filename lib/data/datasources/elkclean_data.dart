import 'package:flutter/material.dart';

class CleanCategory {
  const CleanCategory({
    required this.id,
    required this.code,
    required this.label,
    required this.blurb,
    required this.icon,
    this.star = false,
  });
  final String id, code, label, blurb;
  final IconData icon;
  final bool star;
}

class CleanService {
  const CleanService({
    required this.code,
    required this.name,
    required this.desc,
    required this.price,
    required this.dur,
    required this.checklist,
    this.tag,
    this.steps,
  });
  final String code, name, desc, dur;
  final int price;
  final String? tag;
  final List<String> checklist;
  final List<String>? steps;
}

const cleanCategories = [
  CleanCategory(id: 'cln',  code: 'CLN',  label: 'Home Cleaning',     blurb: 'Standard, deep & move-out',  icon: Icons.auto_awesome),
  CleanCategory(id: 'deep', code: 'DCP',  label: 'Deep Cleaning',      blurb: 'Top-to-bottom detail clean', icon: Icons.cleaning_services),
  CleanCategory(id: 'tnk',  code: 'TNK',  label: 'Water Tank',         blurb: 'Drain, scrub & disinfect',   icon: Icons.water_drop, star: true),
  CleanCategory(id: 'sof',  code: 'SOF',  label: 'Sofa & Upholstery',  blurb: 'Shampoo & protect',          icon: Icons.chair),
  CleanCategory(id: 'crp',  code: 'CRP',  label: 'Carpet & Rug',       blurb: 'Steam deep clean',           icon: Icons.layers),
  CleanCategory(id: 'kit',  code: 'KIT',  label: 'Kitchen Clean',      blurb: 'Degrease & sanitise',        icon: Icons.restaurant),
  CleanCategory(id: 'bth',  code: 'BTH',  label: 'Bathroom Clean',     blurb: 'Sanitise & descale',         icon: Icons.bathtub),
  CleanCategory(id: 'lndr', code: 'LND',  label: 'Laundry & Iron',     blurb: 'Wash, dry & press',          icon: Icons.local_laundry_service),
];

const cleanServices = <String, List<CleanService>>{
  'cln': [
    CleanService(
      code: 'CLN-01', name: 'Standard Home Cleaning',
      desc: 'Dusting, mopping & surface wipe-down.',
      price: 79, dur: '2–3 hrs', tag: 'Popular',
      checklist: ['Dust all surfaces & fittings', 'Vacuum & mop floors', 'Wipe doors, switches, skirting', 'Empty bins & tidy'],
    ),
    CleanService(
      code: 'CLN-02', name: 'Deep Cleaning (Full Home)',
      desc: 'Top-to-bottom detailed clean.',
      price: 199, dur: 'Half day',
      checklist: ['Everything in standard clean', 'Inside cabinets & appliances', 'Descale taps & fittings', 'Detail corners, vents & frames', 'Sanitise high-touch points'],
    ),
    CleanService(
      code: 'CLN-03', name: 'Move-in / Move-out Clean',
      desc: 'Handover-ready spotless finish.',
      price: 249, dur: 'Half day',
      checklist: ['Full deep clean of empty home', 'Inside all cupboards & drawers', 'Mark & scuff removal', 'Balcony & window tracks'],
    ),
  ],
  'tnk': [
    CleanService(
      code: 'TNK-01', name: 'Water Tank Cleaning – up to 1000L',
      desc: 'Drain, scrub, disinfect & refill.',
      price: 149, dur: '60–90 min', tag: 'Featured',
      checklist: ['Full drain & sludge removal', 'Manual scrub of walls & base', 'Anti-bacterial disinfection', 'Fresh water refill', 'Cleanliness photo report'],
      steps: ['Inspect', 'Drain', 'Scrub', 'Disinfect', 'Refill', 'Report'],
    ),
    CleanService(
      code: 'TNK-02', name: 'Large / Underground Tank – 1000L+',
      desc: 'For villas & buildings, per tank.',
      price: 299, dur: '2–3 hrs',
      checklist: ['Confined-space trained crew', 'Full sediment & sludge removal', 'Pressure wash + disinfect', 'Refill & chlorination test', 'Hygiene certificate'],
      steps: ['Inspect', 'Drain', 'Pressure wash', 'Disinfect', 'Refill', 'Certify'],
    ),
    CleanService(
      code: 'TNK-03', name: 'Tank Disinfection Only',
      desc: 'Sanitise without full drain.',
      price: 89, dur: '45 min',
      checklist: ['Surface skim & debris removal', 'Anti-bacterial fogging', 'Safe-to-use water test'],
      steps: ['Inspect', 'Skim', 'Disinfect', 'Test'],
    ),
  ],
  'sof': [
    CleanService(
      code: 'SOF-01', name: 'Sofa Shampoo (per seat)',
      desc: 'Lift stains, odours & dust mites.',
      price: 35, dur: '20 min/seat', tag: 'Popular',
      checklist: ['Pre-treat stains', 'Deep shampoo extraction', 'Deodorise & fast-dry'],
    ),
    CleanService(
      code: 'SOF-02', name: 'Fabric Protection Coat',
      desc: 'Repels future spills & stains.',
      price: 49, dur: '30 min',
      checklist: ['Apply protective layer', 'Cure & buff', 'Spill-resistant finish'],
    ),
  ],
  'crp': [
    CleanService(
      code: 'CRP-01', name: 'Carpet Steam Clean (per room)',
      desc: 'Hot-water extraction deep clean.',
      price: 69, dur: '45 min', tag: 'Popular',
      checklist: ['Vacuum & pre-spray', 'Hot steam extraction', 'Spot-treat stains', 'Speed-dry pass'],
    ),
    CleanService(
      code: 'CRP-02', name: 'Rug Deep Clean',
      desc: 'Per rug, collected if needed.',
      price: 89, dur: 'By size',
      checklist: ['Dust & beat out grit', 'Submersion wash', 'Fibre-safe dry & groom'],
    ),
  ],
  'kit': [
    CleanService(
      code: 'KIT-01', name: 'Kitchen Deep Clean',
      desc: 'Degrease every surface.',
      price: 119, dur: '2 hrs', tag: 'Popular',
      checklist: ['Degrease counters & backsplash', 'Inside & outside cabinets', 'Sink descale & polish', 'Floor scrub'],
    ),
    CleanService(
      code: 'KIT-02', name: 'Oven & Hob Degrease',
      desc: 'Baked-on grime removal.',
      price: 79, dur: '60 min',
      checklist: ['Dismantle racks & trays', 'Soak & scrub', 'Polish glass & hob'],
    ),
  ],
  'bth': [
    CleanService(
      code: 'BTH-01', name: 'Bathroom Sanitation',
      desc: 'Descale, sanitise & shine.',
      price: 59, dur: '45 min', tag: 'Popular',
      checklist: ['Descale taps & glass', 'Disinfect toilet & basin', 'Scrub tiles & floor', 'Mirror & fittings polish'],
    ),
    CleanService(
      code: 'BTH-02', name: 'Grout & Tile Restoration',
      desc: 'Bring tiles back to new.',
      price: 99, dur: '90 min',
      checklist: ['Deep-scrub grout lines', 'Mould & stain treatment', 'Seal & protect'],
    ),
  ],
  'deep': [
    CleanService(
      code: 'DCP-01', name: 'Full Home Deep Clean',
      desc: 'Top-to-bottom detail clean, inside & out.',
      price: 199, dur: 'Half day', tag: 'Popular',
      checklist: ['Everything in standard clean', 'Inside cabinets & appliances', 'Descale taps & fittings', 'Detail corners, vents & frames', 'Sanitise high-touch points'],
    ),
    CleanService(
      code: 'DCP-02', name: 'Move-in / Move-out Clean',
      desc: 'Handover-ready spotless finish.',
      price: 249, dur: 'Half day',
      checklist: ['Full deep clean of empty home', 'Inside all cupboards & drawers', 'Mark & scuff removal', 'Balcony & window tracks'],
    ),
  ],
  'lndr': [
    CleanService(
      code: 'LND-01', name: 'Wash & Iron (per kg)',
      desc: 'Wash, dry and press clothes to perfection.',
      price: 12, dur: '24 hrs', tag: 'Popular',
      checklist: ['Sort & pre-treat stains', 'Machine wash at correct temp', 'Tumble-dry & press', 'Fold & pack neatly'],
    ),
    CleanService(
      code: 'LND-02', name: 'Dry Cleaning (per item)',
      desc: 'Professional dry cleaning for delicates.',
      price: 25, dur: '48 hrs',
      checklist: ['Inspect & tag items', 'Chemical clean', 'Steam press & finish'],
    ),
    CleanService(
      code: 'LND-03', name: 'Curtain Cleaning',
      desc: 'Remove & rehang after full clean.',
      price: 69, dur: '3–4 hrs',
      checklist: ['Remove & label curtains', 'Steam or wash as needed', 'Press & rehang'],
    ),
  ],
};
