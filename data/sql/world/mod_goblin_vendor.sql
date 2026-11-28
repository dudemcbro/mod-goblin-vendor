-- mod-goblin-vendor base world SQL
-- Applied automatically by the worldserver updater from data/sql/world/.
-- Summon item: Goblin Salvage Contract
-- Vendor NPC: Goblin Salvage Broker (temporary summon only)

SET @GV_VENDOR_ENTRY := 55050;
SET @GV_ITEM_ENTRY   := 24278;

-- Source templates from base WotLK data:
-- creature 2684: Rizz Loosebolt (Goblin, Engineering Supplies)
-- item 24278: Flare Gun

DELETE FROM `npc_vendor` WHERE `entry` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template_addon` WHERE `entry` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template_model` WHERE `CreatureID` = @GV_VENDOR_ENTRY;
DELETE FROM `creature_template` WHERE `entry` = @GV_VENDOR_ENTRY;
-- Entries older versions used. 900200 was one too, but it is mod-playerhousing's
-- Krook now, so it is left alone: deleting it removes Krook from every capital.
DELETE FROM `npc_vendor` WHERE `entry` = 70050;
DELETE FROM `creature_template_addon` WHERE `entry` = 70050;
DELETE FROM `creature_template_model` WHERE `CreatureID` = 70050;
DELETE FROM `creature_template` WHERE `entry` = 70050;
DELETE FROM `npc_vendor` WHERE `entry` = 9902200;
DELETE FROM `creature_template_addon` WHERE `entry` = 9902200;
DELETE FROM `creature_template_model` WHERE `CreatureID` = 9902200;
DELETE FROM `creature_template` WHERE `entry` = 9902200;

DROP TEMPORARY TABLE IF EXISTS `tmp_gv_creature_template`;
CREATE TEMPORARY TABLE `tmp_gv_creature_template`
SELECT * FROM `creature_template` WHERE `entry` = 2684;

UPDATE `tmp_gv_creature_template`
SET
    `entry` = @GV_VENDOR_ENTRY,
    `name` = 'GySgt Geargrind',
    `subname` = '8th Crime Battalion',
    `minlevel` = 80,
    `maxlevel` = 80,
    `faction` = 35,
    `npcflag` = 4225,
    `speed_walk` = 1,
    `speed_run` = 1.14286,
    `ScriptName` = ''
WHERE `entry` = 2684;

INSERT INTO `creature_template`
SELECT * FROM `tmp_gv_creature_template`;

DROP TEMPORARY TABLE `tmp_gv_creature_template`;

INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`)
VALUES (@GV_VENDOR_ENTRY, 0, 7192, 1, 1, 12340);

-- Mount display 10666 is a mechanical strider-style mount.
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`)
VALUES (@GV_VENDOR_ENTRY, 0, 10666, 0, 1, 0, 0, '');

INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`, `VerifiedBuild`) VALUES
(@GV_VENDOR_ENTRY, 0, 159, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 1, 1179, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 2, 1205, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 3, 1645, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 4, 8766, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 5, 28399, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 6, 117, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 7, 2287, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 8, 3770, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 9, 4599, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 10, 27856, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 11, 30817, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 12, 2678, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 13, 2692, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 14, 3713, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 15, 17031, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 16, 17032, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 17, 17020, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 18, 17029, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 19, 17028, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 20, 17056, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 21, 17030, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 22, 17034, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 23, 17035, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 24, 17037, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 25, 17038, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 26, 17026, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 27, 17033, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 28, 21177, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 29, 6947, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 30, 3775, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 31, 5237, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 32, 2892, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 33, 10918, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 34, 5140, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 35, 2512, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 36, 2515, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 37, 3030, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 38, 11285, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 39, 18042, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 40, 2516, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 41, 2519, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 42, 3033, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 43, 11284, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 44, 15997, 0, 0, 0, 12340),
(@GV_VENDOR_ENTRY, 45, 37201, 0, 0, 0, 12340);

DELETE FROM `item_template` WHERE `entry` IN (55051, 70051, 900201, 900202, 905001, 9902201, 9902202);

UPDATE `item_template`
SET
    `name` = 'Goblin Salvage Flare Gun',
    `description` = 'Fires a salvage flare and summons GySgt Geargrind for 5 min. Speak with him to open the salvage ledger. Cooldown: 5 min.',
    `spellcooldown_1` = 300000,
    `spellcategorycooldown_1` = 300000,
    `ScriptName` = 'item_goblin_salvage_contract'
WHERE `entry` = @GV_ITEM_ENTRY;

DELETE FROM `playercreateinfo_item`
WHERE `race` = 0 AND `class` = 0 AND `itemid` = @GV_ITEM_ENTRY;

INSERT INTO `playercreateinfo_item` (`race`, `class`, `itemid`, `amount`, `Note`)
VALUES (0, 0, @GV_ITEM_ENTRY, 1, '8th Crime Battalion salvage flare');

-- Sell Goblin Salvage Flare Gun at all innkeepers for 1 copper
UPDATE `item_template` SET `BuyPrice` = 1 WHERE `entry` = @GV_ITEM_ENTRY;

DELETE FROM `npc_vendor` WHERE `item` = @GV_ITEM_ENTRY AND `entry` IN (295,1247,1464,2352,2388,3934,5111,5688,5814,6272,6727,6734,6735,6736,6737,6738,6739,6740,6741,6746,6747,6790,6791,6807,6928,6929,6930,7714,7731,7733,7736,7737,7744,8931,8999,9356,9501,11103,11106,11116,11118,12196,14731,15174,15397,15433,16256,16458,16542,16553,16602,16618,16739,16826,17553,17630,18245,18251,18542,18905,18906,18907,18908,18913,18914,18957,19046,19232,19296,19319,19352,19470,19495,19531,19571,21088,21110,21744,21746,22922,23731,23937,23995,24033,24057,24149,24208,24342,25036,25245,25278,26375,26596,26680,26709,26985,27027,27042,27052,27066,27069,27125,27148,27174,27187,27950,28038,28686,28687,28791,29532,29583,29904,29926,29944,29963,29971,30005,30308,31557,32411,32413,32418,33970,33971,991532);

INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`, `VerifiedBuild`) VALUES
(295, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(1247, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(1464, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(2352, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(2388, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(3934, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(5111, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(5688, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(5814, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6272, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6727, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6734, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6735, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6736, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6737, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6738, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6739, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6740, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6741, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6746, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6747, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6790, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6791, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6807, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6928, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6929, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(6930, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7714, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7731, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7733, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7736, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7737, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(7744, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(8931, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(8999, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(9356, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(9501, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(11103, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(11106, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(11116, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(11118, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(12196, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(14731, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(15174, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(15397, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(15433, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16256, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16458, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16542, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16553, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16602, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16618, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16739, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(16826, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(17553, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(17630, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18245, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18251, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18542, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18905, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18906, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18907, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18908, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18913, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18914, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(18957, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19046, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19232, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19296, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19319, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19352, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19470, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19495, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19531, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(19571, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(21088, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(21110, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(21744, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(21746, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(22922, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(23731, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(23937, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(23995, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(24033, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(24057, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(24149, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(24208, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(24342, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(25036, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(25245, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(25278, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(26375, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(26596, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(26680, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(26709, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(26985, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27027, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27042, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27052, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27066, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27069, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27125, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27148, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27174, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27187, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(27950, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(28038, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(28686, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(28687, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(28791, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29532, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29583, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29904, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29926, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29944, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29963, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(29971, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(30005, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(30308, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(31557, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(32411, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(32413, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(32418, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(33970, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340),
(33971, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340);

-- mod-worgen's Pyrewood innkeeper, only when that module is installed
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`, `VerifiedBuild`)
SELECT `entry`, 0, @GV_ITEM_ENTRY, 0, 0, 0, 12340 FROM `creature_template` WHERE `entry` = 991532;
