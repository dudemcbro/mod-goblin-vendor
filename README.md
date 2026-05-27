mod-goblin-vendor
=================

Adds a portable item that summons a temporary mounted goblin vendor for personal salvage selling.

Features
--------
- Item: `Goblin Salvage Flare Gun` (`item_template.entry = 24278`)
- Summons: `Goblin Salvage Broker` (`creature_template.entry = 55050`)
- Vendor duration: 5 minutes
- Item cooldown: 5 minutes (server-enforced)
- Optional combat restriction: item use is blocked while in combat
- Uses a gossip gate before merchant opens, with randomized broker lines (hook + directive)

Behavior
--------
1. Use item `24278`.
2. Script checks combat + cooldown.
3. Script plays a firework flare cue (`spell 6668`), then summons temp vendor behind the player (`TEMPSUMMON_TIMED_DESPAWN`, 300000 ms) and moves the vendor in.
4. Vendor is mounted on mechanical strider display (`10666`).
5. Player clicks the vendor, gets a randomized flavor line, then chooses `Open salvage ledger.`

Notes
-----
- Cooldown is implemented server-side via spell cooldown storage using spell ID `31333`.
- Item cooldown fields are also set on `item_template` for client-side cooldown spinner display.
- Because AzerothCore persists cooldowns by spell ID, this ID must exist in `spell_dbc`.
- If you want to avoid sharing this cooldown spell with anything else on your realm, change `COOLDOWN_SPELL_ID` in `src/ModGoblinVendor.cpp` to a different valid spell ID.

Install (world DB)
------------------
```
mysql < modules/mod-goblin-vendor/sql/install.sql
```

Rollback
--------
```
mysql < modules/mod-goblin-vendor/sql/rollback.sql
```
