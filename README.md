# mod-goblin-vendor

<img src="icon.png" alt="" width="64" align="right">

An [AzerothCore](https://www.azerothcore.org/) (WotLK 3.3.5a) module that turns the
Flare Gun (item 24278) into a Goblin Salvage Flare Gun, which summons a temporary
mounted goblin vendor so you can sell loot anywhere.

- **Author:** [dudemcbro](https://github.com/dudemcbro)
- **License:** [GNU AGPL v3.0](LICENSE)
- **Works with:** AzerothCore WotLK (3.3.5a). The module only uses standard core APIs,
  with no configuration file and no core patches.

## Features

- **A vendor on demand.** Using the flare gun fires a flare (spell 6668) and summons
  **GySgt Geargrind** (creature 55050), mounted on a mechanical strider, behind you for
  5 minutes.
- **A full shop.** Talking to him gives a random line, then *Open salvage ledger.* opens
  his shop. He buys your items like any vendor and sells a stock of supplies.
- **Server-side cooldown.** 5 minute cooldown, enforced by the server. The flare gun
  cannot be used in combat.
- **Easy to get.** Every new character starts with the flare gun, and every innkeeper
  sells it for 1 copper. With [mod-worgen](https://github.com/dudemcbro/mod-worgen)
  installed, its Pyrewood innkeeper sells it too.

The cooldown is stored on spell 31333, which must exist in `spell_dbc`. To avoid sharing
it with anything else on your realm, change `COOLDOWN_SPELL_ID` in
`src/ModGoblinVendor.cpp` to another valid spell ID.

## Quick start

1. Clone the module into the core's `modules` folder:
   ```sh
   cd <azerothcore>/modules
   git clone https://github.com/dudemcbro/mod-goblin-vendor.git
   ```
2. Re-run CMake and rebuild the core, for example with `./acore.sh compiler build`.
3. Restart `worldserver`. It imports `data/sql/world/mod_goblin_vendor.sql` on startup
   (with the updater enabled, the default). The file can run again safely.

### Upgrading from a manual install

Earlier versions were installed with `mysql < sql/install.sql`. The same data is now
imported automatically on the next start. The file deletes its rows before inserting
them, so running it over a manual install just writes them again.

## Client patch (optional)

Without a client patch everything works, but the flare gun's tooltip and cooldown spinner
show the stock Flare Gun text. `scripts/build_flare_client_mpq.py` patches spell 31333 in
the server's `Spell.dbc` and packs it as `patch-X.MPQ` for players' `Data` folders:

```sh
python3 scripts/build_flare_client_mpq.py --dbc-in <azerothcore>/env/dist/bin/dbc/Spell.dbc
```

It reads the `spell_dbc` column layout from the world database through the `mysql`
client, which takes its login from `~/.my.cnf` or `MYSQL_PWD`. Pass `--mysql` to use
another command. Output goes to `client/` unless `--dbc-out` and `--mpq-out` say
otherwise.

## Updating

```sh
cd <azerothcore>/modules/mod-goblin-vendor
git pull
```

Then re-run CMake, rebuild and restart `worldserver`.

## Removing the module

Run the rollback against the world database, then delete the module folder, re-run CMake
and rebuild:

```sh
mysql acore_world < modules/mod-goblin-vendor/data/sql/rollback/world/mod_goblin_vendor_rollback.sql
```

It removes the vendor, the starting item and the innkeeper listings, and turns item
24278 back into the stock Flare Gun. Flare guns already in bags stay.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/dudemcbro/mod-goblin-vendor). For larger changes, please
open an issue first, and describe how you tested your change.

## License

Licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE).
