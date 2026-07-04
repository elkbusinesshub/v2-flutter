import 'package:flutter/material.dart';

class RepairCategory {
  const RepairCategory({
    required this.id,
    required this.code,
    required this.label,
    required this.blurb,
    required this.icon,
  });
  final String id, code, label, blurb;
  final IconData icon;
}

class RepairService {
  const RepairService({
    required this.code,
    required this.name,
    required this.desc,
    required this.price,
    required this.dur,
    this.tag,
  });
  final String code, name, desc, dur;
  final int price;
  final String? tag;
}

const repairCategories = [
  RepairCategory(id: 'ac',  code: 'AC',  label: 'AC & Cooling', blurb: 'Service, gas, deep clean',  icon: Icons.ac_unit),
  RepairCategory(id: 'plm', code: 'PLM', label: 'Plumbing',     blurb: 'Leaks, taps, drains',       icon: Icons.water_drop),
  RepairCategory(id: 'elc', code: 'ELC', label: 'Electrical',   blurb: 'Wiring, fittings, faults',  icon: Icons.bolt),
  RepairCategory(id: 'cpt', code: 'CPT', label: 'Carpentry',    blurb: 'Doors, furniture, fixes',   icon: Icons.handyman),
  RepairCategory(id: 'pnt', code: 'PNT', label: 'Painting',     blurb: 'Walls, touch-ups',          icon: Icons.format_paint),
  RepairCategory(id: 'gen', code: 'GEN', label: 'Handyman',     blurb: 'Odd jobs & mounting',       icon: Icons.build),
];

const repairServices = <String, List<RepairService>>{
  'ac': [
    RepairService(code: 'AC-01', name: 'AC General Service',       desc: 'Coil clean, filter wash, performance check.',        price: 89,  dur: '45–60 min', tag: 'Popular'),
    RepairService(code: 'AC-02', name: 'AC Deep Cleaning',         desc: 'Full unit dismantle, jet wash, sanitise.',           price: 149, dur: '60–90 min'),
    RepairService(code: 'AC-03', name: 'Gas Refill (R410)',        desc: 'Leak test, vacuum & refill refrigerant.',            price: 199, dur: '60 min'),
    RepairService(code: 'AC-04', name: 'AC Not Cooling – Diagnose', desc: 'Technician inspects & quotes the fix.',             price: 25,  dur: '30 min',    tag: 'Diagnostic'),
  ],
  'plm': [
    RepairService(code: 'PLM-01', name: 'Tap / Mixer Repair',     desc: 'Fix drips, replace cartridge or washer.',            price: 69,  dur: '30–45 min', tag: 'Popular'),
    RepairService(code: 'PLM-02', name: 'Leak Detection & Fix',   desc: 'Trace hidden leaks, seal & test.',                   price: 129, dur: '60 min'),
    RepairService(code: 'PLM-03', name: 'Drain Unblocking',       desc: 'Clear sink, basin or floor drains.',                 price: 99,  dur: '45 min'),
  ],
  'elc': [
    RepairService(code: 'ELC-01', name: 'Switch / Socket Fix',    desc: 'Replace faulty points, safety check.',               price: 59,  dur: '30 min',    tag: 'Popular'),
    RepairService(code: 'ELC-02', name: 'Light Fitting Install',  desc: 'Mount & wire fixtures, chandeliers.',                price: 89,  dur: '45 min'),
    RepairService(code: 'ELC-03', name: 'Power Trip Diagnose',    desc: 'Find the fault behind tripping.',                    price: 25,  dur: '30 min',    tag: 'Diagnostic'),
  ],
  'cpt': [
    RepairService(code: 'CPT-01', name: 'Door Repair / Align',    desc: 'Hinges, locks, sticking doors.',                     price: 79,  dur: '45 min'),
    RepairService(code: 'CPT-02', name: 'Furniture Assembly',     desc: 'Flat-pack build, per unit.',                         price: 99,  dur: '60 min',    tag: 'Popular'),
  ],
  'pnt': [
    RepairService(code: 'PNT-01', name: 'Single Room Painting',   desc: 'Walls prep, two coats, clean finish.',               price: 299, dur: 'Half day',  tag: 'Popular'),
    RepairService(code: 'PNT-02', name: 'Patch & Touch-up',       desc: 'Cracks, dents, small wall areas.',                   price: 119, dur: '60 min'),
  ],
  'gen': [
    RepairService(code: 'GEN-01', name: 'TV / Shelf Mounting',    desc: 'Wall-mount with level & anchors.',                   price: 79,  dur: '45 min',    tag: 'Popular'),
    RepairService(code: 'GEN-02', name: 'Curtain / Blind Fitting', desc: 'Brackets, rods, per window.',                      price: 59,  dur: '30 min'),
  ],
};
