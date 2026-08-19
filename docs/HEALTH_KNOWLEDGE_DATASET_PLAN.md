# DairyCare veterinary knowledge dataset

## Purpose

This dataset supports symptom triage, differentials, safe first aid, prevention,
diagnostic confirmation, and veterinarian-reviewed treatment guidance for cattle,
buffalo, and goats. It is not an autonomous prescription database.

## Authoritative source layers

1. **Pakistan priority:** Punjab Livestock & Dairy Development disease lists and
   surveillance priorities decide which conditions are added first.
2. **Disease identity and control:** WOAH disease pages, technical cards, the
   Terrestrial Manual, and WAHIS provide disease definitions, affected species,
   reportability, surveillance, and control measures.
3. **Field first aid:** FAO primary animal-health and dairy manuals provide safe,
   practical actions suitable for farm users.
4. **Clinical detail:** peer-reviewed veterinary manuals provide signs,
   differentials, confirmation methods, treatment classes, contraindications,
   and prevention.
5. **Pakistan medicine products:** a product, dose, route, withdrawal time, or
   brand enters the model dataset only after its DRAP registration evidence and
   a registered veterinarian's review are stored in DairyCare.

## Record contract

Every disease record must contain:

- canonical code and English/Roman Urdu names;
- supported species and urgency;
- common, key, and emergency symptoms with weights;
- safe immediate care and explicit actions not to take;
- feed and water precautions;
- veterinarian treatment approach (drug class/procedure, never an unreviewed dose);
- diagnostic confirmation guidance;
- prevention, isolation, zoonotic, milk/meat-withdrawal, and reporting notes;
- at least one authoritative source URL and access date;
- positive, ambiguous, emergency, and look-alike evaluation cases.

## Coverage batches

- Existing foundation: 25 conditions and 53 symptom concepts.
- Batch 3: PPR, CCPP, enterotoxemia, trypanosomiasis (surra), fasciolosis,
  Johne's disease, ruminal acidosis, wooden tongue, and post-parturient
  haemoglobinuria.
- Batch 4: bovine tuberculosis, leptospirosis, salmonellosis, listeriosis,
  infectious bovine rhinotracheitis, BVD, Q fever, contagious agalactia,
  sheep/goat pox, bluetongue, tetanus, and botulism.
- Batch 5: calf/neonatal, reproductive, udder, hoof, eye, skin, nutritional,
  toxic, and parasitic differential expansion.

Coverage is measured by veterinarian-approved evaluation cases, not by disease
count alone. A new condition is not released merely because a name was scraped.

## Veterinary acceptance gate

For every batch, the visiting veterinarian reviews source traceability, missing
red flags, unsafe first aid, look-alike separation, medicine legality, dose and
withdrawal evidence, and bilingual clarity. Rejected records remain excluded
from model export until corrected and re-approved.
