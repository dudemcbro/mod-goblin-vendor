#include "AccountMgr.h"
#include "AllCreatureScript.h"
#include "Creature.h"
#include "DBCStores.h"
#include "ScriptedGossip.h"
#include "ItemScript.h"
#include "MotionMaster.h"
#include "Player.h"
#include "PlayerScript.h"
#include "Server/Protocol/Opcodes.h"
#include "ScriptMgr.h"
#include "SpellMgr.h"
#include "TemporarySummon.h"
#include "Util.h"
#include "WorldPacket.h"
#include <array>
#include <algorithm>
#include <cctype>
#include <string>
#include <unordered_map>
#include <vector>

namespace
{
    constexpr uint32 ITEM_GOBLIN_SALVAGE_CONTRACT = 24278;
    constexpr uint32 NPC_GOBLIN_SALVAGE_BROKER    = 55050;

    constexpr uint32 SUMMON_DURATION_MS           = 5 * MINUTE * IN_MILLISECONDS;
    constexpr uint32 ITEM_COOLDOWN_MS             = 5 * MINUTE * IN_MILLISECONDS;

    // Match the item's native use-spell so the client shows normal item cooldown spinner.
    constexpr uint32 COOLDOWN_SPELL_ID            = 31333; // Flare Gun (item 24278)

    constexpr uint32 MECHANICAL_STRIDER_DISPLAY_ID = 10666;
    constexpr uint32 SUMMON_VISUAL_SPELL_ID       = 6668;  // Red Firework
    constexpr float BEHIND_SPAWN_DISTANCE         = 9.0f;
    constexpr float BEHIND_ARRIVE_DISTANCE        = 3.0f;
    constexpr float PI                            = 3.14159265f;
    constexpr uint32 RIDE_IN_POINT_ID             = 1;

    constexpr uint32 ACTION_REFRESH_LINE          = 1;
    constexpr uint32 ACTION_OPEN_VENDOR           = 2;

    constexpr char VENDOR_GOSSIP_TEXT[]           = "Open salvage ledger.";
    #include "BrokerLines.inc"

    std::unordered_map<uint32, std::vector<uint16>> gBrokerLinePools;

    uint16 NextBrokerLineIndex(Player* player)
    {
        uint32 key = player->GetGUID().GetCounter();
        std::vector<uint16>& pool = gBrokerLinePools[key];

        if (pool.empty())
        {
            pool.reserve(static_cast<uint16>(kBrokerLines.size()));
            for (uint16 i = 0; i < kBrokerLines.size(); ++i)
                pool.push_back(i);

            // Fisher-Yates shuffle with server RNG.
            for (int32 i = static_cast<int32>(pool.size()) - 1; i > 0; --i)
            {
                uint32 j = urand(0, static_cast<uint32>(i));
                std::swap(pool[i], pool[j]);
            }
        }

        uint16 idx = pool.back();
        pool.pop_back();
        return idx;
    }

    std::string GetZoneLabel(Player const* player)
    {
        AreaTableEntry const* zone = sAreaTableStore.LookupEntry(player->GetZoneId());
        if (!zone)
            return "Felony Creek";

        uint8 locale = player->GetSession() ? player->GetSession()->GetSessionDbcLocale() : LOCALE_enUS;
        if (locale >= TOTAL_LOCALES)
            locale = LOCALE_enUS;

        if (zone->area_name[locale] && *zone->area_name[locale])
            return zone->area_name[locale];

        if (zone->area_name[LOCALE_enUS] && *zone->area_name[LOCALE_enUS])
            return zone->area_name[LOCALE_enUS];

        return "Felony Creek";
    }

    std::string GetClassLabel(Player const* player)
    {
        switch (player->getClass())
        {
            case CLASS_WARRIOR:      return "Warrior";
            case CLASS_PALADIN:      return "Paladin";
            case CLASS_HUNTER:       return "Hunter";
            case CLASS_ROGUE:        return "Rogue";
            case CLASS_PRIEST:       return "Priest";
            case CLASS_DEATH_KNIGHT: return "Death Knight";
            case CLASS_SHAMAN:       return "Shaman";
            case CLASS_MAGE:         return "Mage";
            case CLASS_WARLOCK:      return "Warlock";
            case CLASS_DRUID:        return "Druid";
            default:                 return "Operator";
        }
    }

    std::string GetRaceLabel(Player const* player)
    {
        switch (player->getRace())
        {
            case RACE_HUMAN:             return "Human";
            case RACE_ORC:               return "Orc";
            case RACE_DWARF:             return "Dwarf";
            case RACE_NIGHTELF:          return "Night Elf";
            case RACE_UNDEAD_PLAYER:     return "Undead";
            case RACE_TAUREN:            return "Tauren";
            case RACE_GNOME:             return "Gnome";
            case RACE_TROLL:             return "Troll";
            case RACE_BLOODELF:          return "Blood Elf";
            case RACE_DRAENEI:           return "Draenei";
            default:                     return "Recruit";
        }
    }

    void ReplaceToken(std::string& text, std::string const& from, std::string const& to)
    {
        size_t startPos = 0;
        while ((startPos = text.find(from, startPos)) != std::string::npos)
        {
            text.replace(startPos, from.length(), to);
            startPos += to.length();
        }
    }

    std::string BuildBrokerLine(Player* player)
    {
        // Fixed pool of 100 full lines, no repeats until exhausted.
        uint32 lineIndex = NextBrokerLineIndex(player);
        std::string line = std::string(kBrokerLines[lineIndex]);

        ReplaceToken(line, "{name}", player->GetName());
        ReplaceToken(line, "{race}", GetRaceLabel(player));
        ReplaceToken(line, "{class}", GetClassLabel(player));
        ReplaceToken(line, "{zone}", GetZoneLabel(player));
        return line;
    }

    bool IsBotAccountName(std::string accountName)
    {
        std::transform(accountName.begin(), accountName.end(), accountName.begin(),
            [](unsigned char c) { return std::toupper(c); });
        return accountName.rfind("RNDBOT", 0) == 0;
    }
}

class item_goblin_salvage_contract final : public ItemScript
{
public:
    item_goblin_salvage_contract() : ItemScript("item_goblin_salvage_contract") {}

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (!player || !item || item->GetEntry() != ITEM_GOBLIN_SALVAGE_CONTRACT)
            return true;

        if (player->IsInCombat())
        {
            player->SendEquipError(EQUIP_ERR_NOT_IN_COMBAT, item, nullptr);
            return true;
        }

        if (player->HasSpellCooldown(COOLDOWN_SPELL_ID))
        {
            player->SendEquipError(EQUIP_ERR_CANT_DO_RIGHT_NOW, item, nullptr);
            return true;
        }

        if (player->FindNearestCreature(NPC_GOBLIN_SALVAGE_BROKER, 45.0f, true))
        {
            player->SendEquipError(EQUIP_ERR_CANT_DO_RIGHT_NOW, item, nullptr);
            return true;
        }

        // Fire flare/firework cue first, then summon the broker behind the player and move in.
        player->CastSpell(player, SUMMON_VISUAL_SPELL_ID, true);

        Position summonPos = player->GetFirstCollisionPosition(BEHIND_SPAWN_DISTANCE, PI);
        Position arrivePos = player->GetFirstCollisionPosition(BEHIND_ARRIVE_DISTANCE, PI);

        float summonZ = summonPos.GetPositionZ();
        player->UpdateGroundPositionZ(summonPos.GetPositionX(), summonPos.GetPositionY(), summonZ);
        summonPos.m_positionZ = summonZ;

        float arriveZ = arrivePos.GetPositionZ();
        player->UpdateGroundPositionZ(arrivePos.GetPositionX(), arrivePos.GetPositionY(), arriveZ);
        arrivePos.m_positionZ = arriveZ;

        Creature* broker = player->SummonCreature(
            NPC_GOBLIN_SALVAGE_BROKER,
            summonPos.GetPositionX(),
            summonPos.GetPositionY(),
            summonPos.GetPositionZ(),
            player->GetOrientation(),
            TEMPSUMMON_TIMED_DESPAWN,
            SUMMON_DURATION_MS
        );

        if (!broker)
        {
            player->SendEquipError(EQUIP_ERR_CANT_DO_RIGHT_NOW, item, nullptr);
            return true;
        }

        broker->SetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID, MECHANICAL_STRIDER_DISPLAY_ID);
        broker->SetWalk(false);
        broker->GetMotionMaster()->MovePoint(RIDE_IN_POINT_ID, arrivePos);

        if (SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(COOLDOWN_SPELL_ID))
            player->AddSpellAndCategoryCooldowns(spellInfo, item->GetEntry());
        else
            player->AddSpellCooldown(COOLDOWN_SPELL_ID, item->GetEntry(), ITEM_COOLDOWN_MS, true);

        // Force item cooldown spinner on action bar/inventory for this item use.
        WorldPacket data(SMSG_ITEM_COOLDOWN, 12);
        data << item->GetGUID();
        data << uint32(COOLDOWN_SPELL_ID);
        player->SendDirectMessage(&data);

        return true;
    }
};

class all_goblin_salvage_broker_gossip final : public AllCreatureScript
{
public:
    all_goblin_salvage_broker_gossip() : AllCreatureScript("all_goblin_salvage_broker_gossip") {}

    bool CanCreatureGossipHello(Player* player, Creature* creature) override
    {
        if (!creature || creature->GetEntry() != NPC_GOBLIN_SALVAGE_BROKER)
            return false;

        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, BuildBrokerLine(player), GOSSIP_SENDER_MAIN, ACTION_REFRESH_LINE);
        AddGossipItemFor(player, GOSSIP_ICON_VENDOR, VENDOR_GOSSIP_TEXT, GOSSIP_SENDER_MAIN, ACTION_OPEN_VENDOR);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }

    bool CanCreatureGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        if (!creature || creature->GetEntry() != NPC_GOBLIN_SALVAGE_BROKER)
            return false;

        ClearGossipMenuFor(player);

        if (action == ACTION_OPEN_VENDOR)
        {
            CloseGossipMenuFor(player);
            player->GetSession()->SendListInventory(creature->GetGUID());
            return true;
        }

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, BuildBrokerLine(player), GOSSIP_SENDER_MAIN, ACTION_REFRESH_LINE);
        AddGossipItemFor(player, GOSSIP_ICON_VENDOR, VENDOR_GOSSIP_TEXT, GOSSIP_SENDER_MAIN, ACTION_OPEN_VENDOR);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }
};

class player_goblin_salvage_starter final : public PlayerScript
{
public:
    player_goblin_salvage_starter() : PlayerScript("player_goblin_salvage_starter") {}

    void OnPlayerCreate(Player* player) override
    {
        if (!player)
            return;

        WorldSession* session = player->GetSession();
        if (!session)
            return;

        std::string accountName;
        if (!AccountMgr::GetName(session->GetAccountId(), accountName) || IsBotAccountName(accountName))
            return;

        if (!player->HasItemCount(ITEM_GOBLIN_SALVAGE_CONTRACT, 1, true))
            player->AddItem(ITEM_GOBLIN_SALVAGE_CONTRACT, 1);
    }
};

void Addmod_goblin_vendorScripts()
{
    new item_goblin_salvage_contract();
    new all_goblin_salvage_broker_gossip();
    new player_goblin_salvage_starter();
}
