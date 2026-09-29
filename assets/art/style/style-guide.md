# Art Style Guide — Immunity War

- Source of truth: `docs/game-design/04-art-audio-bible.md` (approved 2026-08-23)
- Pipeline contract: `game-asset-pipeline` skill
- Provider: MiniMax `mmx image` (image-01). Anchor contract is **not enforceable** with this provider — see notes.

## Universal prompt prefix (must lead every asset prompt)

```
flat vector 2D game sprite, soft neon glow rim light, dark deep-green microscopic world, two-tone flat shading with single highlight, no outline, cute but composed mood, readable silhouette at 40px, no text
```

Subject sentence follows the prefix. Subject leads → provider drifts to photoreal; style-first → style transfers.

## Palette (locked, never drift)

### Cells
| ID | Role | Color | Notes |
|---|---|---|---|
| CH-MAC | Macrophage | #28D2A3 | 듬직한 맏형, 큰 둥근 몸+짧은 위족 |
| CH-NEU | Neutrophil | #F2D95C | 성급한, 삐죽한 돌기 6개 |
| CH-BCL | B-cell | #63B3FF | Y자 안테나, 침착 |
| CH-DEN | Dendritic | #B78CFF | 별형 가지돌기, 큰 눈 |
| CH-COM | Complement | #7FE8D8 | 링 3개 결합, 눈 없음 |
| CH-KIL | Killer T | #FF8FB1 | 유선형+단검 돌기 |
| CH-HEL | Helper T | #FFC978 | 둥근 몸+방송 안테나 |
| CH-MEM | Memory | #9BB8FF | 책갈피 리본, 졸린 눈 |

### Enemies
| ID | Type | Color |
|---|---|---|
| EN-CLU | 군집 | #F45656 |
| EN-ARM | 두꺼운 (armored) | #C35CFF |
| EN-FAS | 빠른 (fast) | #FF8D42 |
| EN-TOX | 독소 (toxin) | #A6E22E |
| EN-SPO | 포자 (spore) | #E06CD9 |
| EN-BOS | 보스 | #8A2BE2 본체 + #BFE9FF 실드 |

### Functional
- Reward cytokine: #FFD966
- Danger: #FF6A55
- Background deep: #061615 / #0B2D2A

## Style rules

- 2D flat vector, **no outline**, two-tone flat shading + single specular highlight
- Soft neon glow rim light (each character self-emits)
- Cute but composed — 점 눈 + 단순 입, **no humanoid anatomy**
- Readable silhouette at 40px (cells/enemies), 24px (icons)
- No text in any image (text is added by engine)
- Transparent background unless noted otherwise

## Shape language

- Allies: curved blob silhouettes
- Enemies: capsule/rod with angular tag variations (armored=각진 외피, fast=유선형, toxin=주둥이, spore=캡슐+가시)
- Allies and enemies never share curvature

## Subject prompt fragments (use after the prefix)

### Cells
- **macrophage**: "large round teal-green cell #28D2A3 with short pseudopods and half-moon calm eyes, the biggest and squishiest of all"
- **neutrophil**: "yellow #F2D95C cell with six pointy spikes and bulging dot eyes, looks eager and a bit reckless"
- **bcell**: "tall sky-blue #63B3FF cell with two Y-shaped antibody antennas, calm narrow eyes"
- **dendritic**: "lavender #B78CFF star-shaped cell with branching dendrites, large curious eyes"
- **complement**: "three small mint-cyan #7FE8D8 rings fused together, no eyes, looks like a non-living cascade"
- "killer_t": "sleek pink #FF8FB1 cell with dagger-like spikes, narrow slit eyes"
- "helper_t": "round warm-orange #FFC978 cell with a broadcast antenna on top, gentle smile"
- "memory": "soft-blue #9BB8FF cell with a bookmark ribbon motif, sleepy half-closed eyes"

### Enemies
- "cluster_bacteria": "capsule-shaped red #F45656 bacteria in a tight cluster, no eyes, slightly menacing"
- "armored_bacteria": "angular thick purple #C35CFF bacterium with plated armor shell"
- "fast_bacteria": "streamlined orange #FF8D42 bacterium, aerodynamic, pointy ends"
- "toxin_bacteria": "lime-green #A6E22E bacterium with a nozzle-like mouth, drooling toxin droplets"
- "spore_bacteria": "magenta #E06CD9 capsule bacterium with sharp spore spikes around the body"
- "boss_bacteria": "massive purple #8A2BE2 boss bacterium with a cyan #BFE9FF glowing energy shield, glowing core visible through the shield"

### Skill icons (compact 128x128 final, 512x512 source)
- "predator_swirl": "teal swirling vortex effect icon, looks like a predator pulling things in"
- "inflammation_burst": "yellow-to-orange expanding ring burst icon"
- "antibody_marker": "Y-shaped antibody marker icon, cyan-white #BFE9FF"
- "dendrite_sense": "purple #B78CFF branching sensor spike icon"
- "complement_cascade": "three stacked rings cascading icon, mint-cyan #7FE8D8"
- "cytotoxic_strike": "pink #FF8FB1 blade slash icon"
- "cytokine_signal": "warm-orange #FFC978 broadcasting wave icon"
- "memory_decoy": "soft-blue #9BB8FF book-mark decoy icon"

### Upgrade icons
- "upg_mac", "upg_neu", "upg_bcl", "upg_den", "upg_com", "upg_kil", "upg_hel", "upg_mem": "small plus-mark upgrade icon for {role}, glowing accent"
- "upg_base": "stone wall shield with cyan glow icon"
- "upg_skill_cd": "circular clock arrow with shrinking arc icon"
- "upg_cytokine_yield": "gold hexagonal crystal with up-arrow icon"
- "upg_reinforce_charge": "lightning bolt over a progress bar icon"

### Chapter backgrounds (full canvas 1024x1536)
- "bg_ch1_skin": "dark microscopic cross-section of wounded skin, faint red cut line, epidermis tissue"
- "bg_ch2_airway": "dark airway tube cross-section with cilia and faint mucus haze"
- "bg_ch3_intestine": "dark intestinal villi pillars with glistening mucus surface"

### Learning cards (1024x768 final)
One per concept listed in 04-art-audio-bible.md:
- "learn_macrophage", "learn_neutrophil", "learn_bcell", "learn_dendritic",
- "learn_complement", "learn_killert", "learn_helpert", "learn_memory",
- "learn_opsonization", "learn_cytokine", "learn_inflammation"
Subject prompt: "single illustrated concept card for the immune concept of {name}, dark deep-green background with a glowing soft-lit microscopic vignette, one clear visual metaphor, no text"

### Home key visual (1024x1408)
- "key_visual_home": "microscopic world battle key visual, base line on the left, teal cell squad in the center facing a tide of red and purple bacteria on the right, depth-layered atmosphere, dark deep-green mood"

## Provider note (MiniMax reality, verified 2026-09-13)

- `--subject-ref type=character` only transfers **front-facing portrait identity**, not style or illustration identity. Anchor-attached icons lost outline and a referenced mascot came back as a different character.
- Therefore this project does **not** maintain an enforced anchor. Style consistency relies entirely on the universal prompt prefix + locked palette hex codes. Each asset is generated independently; batch QA (contact sheet) is the consistency gate.
- Same prompt + `--seed` reproduces pixel-identically (validated). Use seeds during regeneration so prior finals are diffed against the same raw.