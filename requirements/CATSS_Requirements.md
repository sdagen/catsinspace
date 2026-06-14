# CATSS — Cislunar Autonomous Tended Station (for cats)
## Stakeholder Needs & System Requirements Baseline

**Status:** Draft for systems-engineering review · **Date:** 2026-06-14
**Source of truth:** `CATSS_StakeholderNeeds.slreqx`, `CATSS_SystemRequirements.slreqx` (Requirements Toolbox, R2025b)
**Rebuild:** run `build_catss_requirements.m`

---

## 1. Purpose & scope

This document captures the **stakeholder needs** and derived **system requirements** for CATSS, a crewed/tended space station housing a colony of cats. It is the handoff artifact for the SE team to begin generating and evaluating candidate **architectures in trade studies**.

Requirements are **solution-neutral**: they state *what* the station must achieve, not *how*. Bracketed **[TBD]** (to be determined) and **[TBR]** (to be reviewed/resolved) values are deliberate open trades — see §6.

### Mission context (assumptions driving the baseline)

| Parameter | Value |
|---|---|
| Colony size | ~50 cats (medium scale) |
| Orbit | Cislunar, NRHO-class |
| Resupply autonomy | 12 months threshold / 18 months objective |
| Occupancy | Continuous; human and/or robotic caretaking |
| Prioritized drivers | **Cost & scalability**, **feline welfare & behavior** |

> These assumptions are themselves trade inputs. If the team changes colony size, orbit, or autonomy, the quantitative requirements (e.g., SR-007, SR-019, SR-028) must be re-derived.

---

## 2. Stakeholders

Cats (occupants) · Mission sponsor · Operators/caretakers · Veterinary staff · Resupply provider · Safety & regulatory authorities.

---

## 3. Stakeholder Needs (SN)

Priority key: **H** = High, **M** = Medium, **L** = Low.

### A. Feline Welfare & Behavior
| ID | Pri | Need | Rationale |
|---|---|---|---|
| SN-001 | H | Cats remain healthy and behave naturally for the full mission. | The colony is why the station exists; sustained health is the top measure of success. |
| SN-002 | H | Species-appropriate environment (territory, climbing, scratching, refuge) in microgravity. | Behavioral health depends on an environment affording natural behaviors. |
| SN-003 | H | Colony social structure managed to minimize stress, aggression, competition. | Cats are territorial; unmanaged grouping drives conflict and stress illness. |
| SN-004 | H | Nutrition and hydration suited to feline physiology in microgravity. | Obligate carnivores with low voluntary water intake; improper provision causes disease. |
| SN-005 | H | Sanitation and waste management keeping cats clean and habitat hygienic. | Hygiene and elimination behavior are essential to health and a habitable cabin. |
| SN-006 | H | Continuous health monitoring with veterinary care available. | Early detection/treatment is the only mitigation with no rapid return-to-Earth. |
| SN-007 | M | Day/night and sensory environment supporting circadian rhythm and comfort. | Disrupted circadian/sensory environments degrade welfare over long missions. |

### B. Cost & Scalability
| ID | Pri | Need | Rationale |
|---|---|---|---|
| SN-008 | H | Affordable to develop, launch, and operate. | Affordability gates feasibility of the venture. |
| SN-009 | H | Scales in colony size through modular growth without redesign. | Growth must not require redesign; modularity controls cost/risk. |
| SN-010 | H | Sustainable, cost-effective resupply logistics. | Recurring logistics dominate life-cycle cost. |
| SN-011 | H | Minimized caretaking workload (human and/or robotic). | Caretaker labor is a major recurring cost and crew-time constraint. |

### C. Mission & Autonomy
| ID | Pri | Need | Rationale |
|---|---|---|---|
| SN-012 | H | Operate in cislunar orbit; sustain colony autonomously between resupply. | Cislunar distance makes frequent resupply/intervention infeasible. |
| SN-013 | H | Protect occupants from cislunar radiation and thermal environment. | Beyond the geomagnetic shield, radiation and thermal extremes are life-limiting. |

### D. Safety & Compliance
| ID | Pri | Need | Rationale |
|---|---|---|---|
| SN-014 | H | Protect occupants/caretakers from station hazards (fire, depress., LoLS). | Classic catastrophic spaceflight hazards; protection is mandatory. |
| SN-015 | M | Comply with applicable spaceflight-safety and animal-welfare standards. | Required for approval to launch and operate. |

---

## 4. System Requirements (SR)

Each requirement lists its **Derives-from** stakeholder need(s) and intended **verification method** (T=Test, A=Analysis, I=Inspection, D=Demonstration).

### 1. Environmental Control & Life Support (ECLSS)
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-001 | H | T | Maintain cabin total pressure 101.3 kPa ±5% in occupied volumes. | SN-014, SN-013 |
| SR-002 | H | T | Maintain O₂ partial pressure 19.5–23.1 kPa. | SN-001, SN-014 |
| SR-003 | H | T | Maintain CO₂ partial pressure < 0.4 kPa (24-h avg). | SN-001 |
| SR-004 | H | T | Maintain cabin air temperature 20–28 °C **[TBR]**. | SN-007, SN-001 |
| SR-005 | M | T | Maintain relative humidity 30–70%. | SN-001 |
| SR-006 | H | A | Recover/recycle ≥ 90% of cabin water by mass **[TBR]**. | SN-010, SN-012 |
| SR-007 | H | A | CO₂ removal sized for 50 cats + up to **[TBD]** caretakers + **[TBD]** margin. | SN-001, SN-014 |
| SR-008 | M | T | Filter particulates incl. dander/litter dust to **[TBD]** limits. | SN-002, SN-001 |
| SR-009 | M | D | Control cabin odor to **[TBD]** acceptability limits. | SN-002 |

### 2. Habitat & Feline Welfare
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-010 | H | A | Provide ≥ 1.5 m³ usable habitable volume per cat **[TBR]**. | SN-002 |
| SR-011 | H | A | Provide ≥ 1.0 m² perch/climb surface per cat in 3D **[TBR]**. | SN-002 |
| SR-012 | H | D | Provide claw-compatible grip surfaces throughout occupied volumes. | SN-002 |
| SR-013 | M | I | Scratching surfaces ≥ 1 per 6 cats **[TBR]**. | SN-002 |
| SR-014 | H | I | Enclosed refuge spaces ≥ 1 per cat. | SN-003, SN-002 |
| SR-015 | H | D | Reconfigurable partitioning into social groups ≤ 12 cats **[TBR]**. | SN-003 |
| SR-016 | M | T | Programmable 24-h circadian lighting, adjustable photoperiod/intensity. | SN-007 |
| SR-017 | M | T | Limit sustained noise ≤ 60 dBA **[TBR]**. | SN-007, SN-003 |
| SR-018 | L | D | Provide behavioral enrichment features in each habitat zone. | SN-002 |

### 3. Food, Water & Waste
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-019 | H | A | Store/dispense food for 50 cats over max resupply interval + 30% reserve. | SN-004, SN-012 |
| SR-020 | H | A | Provide potable water ≥ 200 mL/cat/day + **[TBD]** reserve. | SN-004, SN-012 |
| SR-021 | M | I | Microgravity feeding stations ≥ 1 per 8 cats **[TBR]**. | SN-004 |
| SR-022 | H | T | Capture/contain/process waste with no uncontrolled cabin release. | SN-005, SN-014 |
| SR-023 | M | I | Elimination/litter stations ≥ 1 per 4 cats **[TBR]**. | SN-005 |
| SR-024 | M | A | Recover usable resources (e.g., water) from waste where practical **[TBD]**. | SN-010, SN-012 |

### 4. Health & Veterinary
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-025 | H | D | Uniquely identify each cat; monitor mass, activity, feeding, temperature. | SN-006 |
| SR-026 | H | I | Medical isolation/quarantine for ≥ 10% of colony at once **[TBR]**. | SN-006 |
| SR-027 | M | D | Veterinary area for examination and minor procedures. | SN-006 |

### 5. Operations & Autonomy
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-028 | H | A | Sustain colony w/o resupply ≥ 12 mo (threshold) / 18 mo (objective). | SN-012 |
| SR-029 | H | A | Retain ≥ 15% consumables margin at end of each interval **[TBR]**. | SN-012, SN-010 |
| SR-030 | H | D | Automate feeding/watering/waste so caretaking ≤ **[TBD]** hrs/day. | SN-011 |
| SR-031 | H | T | Autonomously detect, isolate, annunciate life-support-critical faults. | SN-014 |
| SR-032 | M | T | Support Earth comms tolerant of cislunar link availability/latency. | SN-012 |

### 6. Safety & Survivability
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-033 | H | A | Single-fault tolerant for any failure causing loss of colony. | SN-014 |
| SR-034 | H | T | Detect and suppress fire in occupied and equipment volumes. | SN-014 |
| SR-035 | H | A | Safe-haven protecting all occupants ≥ 24 h during depress./contam. **[TBR]**. | SN-014 |
| SR-036 | H | A | Limit radiation to **[TBD]** dose limits; provide SPE sheltering. | SN-013 |
| SR-037 | H | T | Emergency power to critical loads ≥ 24 h after primary loss **[TBR]**. | SN-014 |

### 7. Architecture, Cost & Interfaces
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-038 | H | A | Add habitat capacity in increments ≤ 12 cats without redesign. | SN-009 |
| SR-039 | H | A | Each module within reference fairing envelope (**[TBD]** kg, **[TBD]** m). | SN-008 |
| SR-040 | H | A | Meet design-to-cost: **[TBD]** dev, **[TBD]** recurring/module. | SN-008 |
| SR-041 | M | I | Standardized berthing/docking & resupply interfaces across modules. | SN-009, SN-010 |
| SR-042 | M | A | Accommodate resupply visits no more frequent than SR-028 interval. | SN-010 |

### 8. Compliance
| ID | Pri | V | Requirement | Derives |
|---|---|---|---|---|
| SR-043 | M | I | Comply with tailored human-spaceflight safety standards **[TBD set]**. | SN-015 |
| SR-044 | M | I | Comply with tailored animal-welfare standards for spaceflight **[TBD set]**. | SN-015 |

---

## 5. Traceability — Need → derived requirements

| Stakeholder need | Derived system requirements |
|---|---|
| SN-001 | SR-002, SR-003, SR-004, SR-007, SR-008 |
| SN-002 | SR-008, SR-009, SR-010, SR-011, SR-012, SR-013, SR-014, SR-018 |
| SN-003 | SR-014, SR-015, SR-017 |
| SN-004 | SR-019, SR-020, SR-021 |
| SN-005 | SR-022, SR-023 |
| SN-006 | SR-025, SR-026, SR-027 |
| SN-007 | SR-004, SR-016, SR-017 |
| SN-008 | SR-039, SR-040 |
| SN-009 | SR-038, SR-041 |
| SN-010 | SR-006, SR-024, SR-029, SR-041, SR-042 |
| SN-011 | SR-030 |
| SN-012 | SR-006, SR-019, SR-020, SR-024, SR-028, SR-029, SR-032 |
| SN-013 | SR-001, SR-036 |
| SN-014 | SR-001, SR-002, SR-007, SR-022, SR-031, SR-033, SR-034, SR-035, SR-037 |
| SN-015 | SR-043, SR-044 |

**Coverage:** 15/15 needs derived (automated check passes in `build_catss_requirements.m`).

---

## 6. Open trades — [TBD] / [TBR] to resolve in trade studies

These are intentionally unset so the architecture team can trade them:

- **Sizing inputs:** caretaker count (SR-007), reserves/margins (SR-007, SR-020, SR-029).
- **Welfare quantities (pending welfare study):** habitable volume/cat (SR-010), perch area/cat (SR-011), scratching/feeding/litter ratios (SR-013, SR-021, SR-023), noise limit (SR-017), temperature band (SR-004).
- **Closed-loop targets:** water recovery fraction (SR-006), waste resource recovery (SR-024).
- **Cost & launch:** fairing mass/volume envelope (SR-039), design-to-cost targets (SR-040).
- **Safety durations & limits:** safe-haven duration (SR-035), radiation dose limits (SR-036), emergency-power duration (SR-037).
- **Caretaking workload cap (cost driver):** caretaker-hours/day (SR-030).
- **Compliance:** applicable standard sets (SR-043, SR-044).

---

## 7. Notes for the architecture team

- Requirements are deliberately **solution-neutral** — no architecture (module count, life-support tech, automation approach) is presupposed. Use these as the evaluation criteria backbone for trade studies.
- The **prioritized drivers** (cost/scalability + welfare) are reflected in the High-priority concentration of sections 2, 3, 5, and 7. Trade-study figures of merit should weight these.
- When you instantiate an architecture, create an **implementation/allocation link set** from these SRs to your System Composer components so coverage and trades stay traceable.
- Recommend establishing **measures of effectiveness (MOEs)** from the [TBR] welfare quantities before the first trade gate.
