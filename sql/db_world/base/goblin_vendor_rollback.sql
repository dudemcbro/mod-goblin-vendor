-- mod-goblin-vendor rollback world SQL

SET @GV_VENDOR_ENTRY := 900200;
SET @GV_VENDOR_ENTRY_NEW := 55050;
SET @GV_ITEM_ENTRY_NEW   := 24278;

DELETE FROM `npc_vendor` WHERE `entry` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template_addon` WHERE `entry` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template_model` WHERE `CreatureID` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template` WHERE `entry` = @GV_VENDOR_ENTRY;
DELETE FROM `npc_vendor` WHERE `entry` = 70050;
DELETE FROM `creature_template_addon` WHERE `entry` = 70050;
DELETE FROM `creature_template_model` WHERE `CreatureID` = 70050;
DELETE FROM `creature_template` WHERE `entry` = 70050;
DELETE FROM `npc_vendor` WHERE `entry` = 9902200;
DELETE FROM `creature_template_addon` WHERE `entry` = 9902200;
DELETE FROM `creature_template_model` WHERE `CreatureID` = 9902200;
DELETE FROM `creature_template` WHERE `entry` = 9902200;
DELETE FROM `npc_vendor` WHERE `entry` = @GV_VENDOR_ENTRY_NEW;
DELETE FROM `creature_template_addon` WHERE `entry` = @GV_VENDOR_ENTRY_NEW;
DELETE FROM `creature_template_model` WHERE `CreatureID` = @GV_VENDOR_ENTRY_NEW;
DELETE FROM `creature_template` WHERE `entry` = @GV_VENDOR_ENTRY_NEW;
DELETE FROM `item_template` WHERE `entry` IN (55051, 70051, 900201, 900202, 905001, 9902201, 9902202);
UPDATE `item_template`
SET
    `name` = 'Flare Gun',
    `description` = '',
    `spellcooldown_1` = -1,
    `spellcategorycooldown_1` = -1,
    `ScriptName` = ''
WHERE `entry` = @GV_ITEM_ENTRY_NEW;

DELETE FROM `playercreateinfo_item`
WHERE `race` = 0 AND `class` = 0 AND `itemid` = @GV_ITEM_ENTRY_NEW;
