SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET GLOBAL log_bin_trust_function_creators = 1;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `zombie_survival`
--

DELIMITER $$
--
-- Procedimientos
--

DROP PROCEDURE IF EXISTS `checkAllVencimientos`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `checkAllVencimientos` ()  BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE a INT;
    DECLARE cur1 CURSOR FOR SELECT a.charId FROM Admin a WHERE a.vencido=0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    
    read_loop:LOOP
		FETCH cur1 INTO a;
        IF done THEN
			LEAVE read_loop;
		END IF;
        CALL check_fecha_admin(a);
	END LOOP;
    
    CLOSE cur1;
END$$

DROP PROCEDURE IF EXISTS `checkAllVipPrueba`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `checkAllVipPrueba` ()  BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE a INT;
    DECLARE cur1 CURSOR FOR SELECT a.idChar FROM vipprueba a WHERE a.vencido=0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    
    read_loop:LOOP
		FETCH cur1 INTO a;
        IF done THEN
			LEAVE read_loop;
		END IF;
        CALL checkFechaPrueba(a);
	END LOOP;
    
    CLOSE cur1;
END$$

DROP PROCEDURE IF EXISTS `checkFechaPrueba`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `checkFechaPrueba` (IN `id` INT)  BEGIN
    SET @fechaV = (SELECT fechaFin FROM VipPrueba WHERE idChar = id AND vencido = false);
    IF @fechaV < NOW() THEN
		START TRANSACTION;
		UPDATE VipPrueba v SET vencido = 1 WHERE v.idChar = id;
        UPDATE Characters c SET expboost = 1 WHERE c.id = id;
        COMMIT;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `check_fecha_admin`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `check_fecha_admin` (IN `id` INT)  BEGIN
    SET @fechaV = (SELECT DISTINCT fechaVencimiento FROM Admin WHERE charId = id AND vencido = false);
    SET @tag = (SELECT DISTINCT tag FROM Admin WHERE charId=id AND vencido=0);
    IF @fechaV < NOW() THEN
		START TRANSACTION;
		UPDATE Admin a SET vencido = 1 WHERE a.charId = id;
        UPDATE Characters c SET expboost = 1 WHERE c.id = id;
        UPDATE TagsXCharacter t SET t.activo = 0 WHERE t.idTag=@tag AND t.idChar = id;
        COMMIT;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `createCharacter`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `createCharacter` (IN `steam_id` INT, IN `cName` VARCHAR(64))  BEGIN
	START TRANSACTION;
	SET @id = (SELECT id FROM Players WHERE steamid=steam_id);
    INSERT INTO Characters(idPlayer, nombre) VALUES(@id, cName COLLATE utf8mb4_unicode_ci);
    SET @charId = (SELECT id FROM Characters WHERE nombre=cName);
    INSERT INTO HatsXCharacter(idHat, idCharacter, activo) VALUES(0, @charId, 1);
    INSERT INTO TagsXCharacter(idTag, idChar, activo) VALUES(0, @charId, 1);
	COMMIT;
END$$

DROP PROCEDURE IF EXISTS `giveHatToClient`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `giveHatToClient` (IN `idChar` INT, IN `idHat` INT)  BEGIN
	INSERT INTO HatsXCharacter(idHat, idCharacter, activo) VALUES(idHat, idChar, 1);
END$$

DROP PROCEDURE IF EXISTS `givePointsToVips`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `givePointsToVips` ()  BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE a CHAR(32);
	DECLARE cur1 CURSOR FOR SELECT c.nombre FROM Characters c RIGHT JOIN Admin a ON(a.charId = c.id);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    
    read_loop:LOOP
		FETCH cur1 INTO a;
        IF done THEN
			LEAVE read_loop;
		END IF;
        CALL registerAdmin(a, current_timestamp(), 31, 5, '[GOLDEN-VIP]');
	END LOOP;
    
END$$

DROP PROCEDURE IF EXISTS `giveTagToClient`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `giveTagToClient` (IN `nompj` VARCHAR(45), IN `nom` VARCHAR(45))  BEGIN
    SET @idChar = (SELECT id FROM Characters WHERE nombre=nompj);
	SET @idTag = (SELECT idTag FROM Tags WHERE nombre LIKE CONCAT(nom, '%') COLLATE utf8mb4_unicode_ci);
    SET @hasTag = (SELECT COUNT(*) FROM TagsXCharacter WHERE idTag=@idTag AND idChar=@idChar);
    
	IF @hasTag > 0 THEN UPDATE TagsXCharacter SET activo=1 WHERE idTag=@idTag AND idChar=@idChar;
	ELSE INSERT INTO TagsXCharacter VALUES(@idTag, @idChar, 1);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `registerAdminById`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `registerAdminById` (IN `idChar` INT, IN `fechaInicio` TIMESTAMP, IN `days` INT, IN `boost` FLOAT)  BEGIN
	SET @idTag = 0;
    SET @hasVipTest = (SELECT COUNT(*) FROM VipPrueba v WHERE v.idChar=idChar AND v.vencido = 0);
    START TRANSACTION;
    
    IF @hasVipTest > 0 THEN 
		UPDATE VipPrueba SET vencido = 1 WHERE idChar=idChar;
    END IF;
    
    SET @idTag = 3+boost;
    
    
    SET @hasTag = (SELECT COUNT(*) FROM TagsXCharacter tc WHERE tc.idTag=@idTag AND tc.idChar=idChar);
    
    INSERT INTO Admin(charId, fechaInicio, fechaVencimiento, boost, tag) VALUES(idChar, fechaInicio, fechaInicio + INTERVAL days DAY, boost, @idTag);
    
    UPDATE Characters SET expboost=boost, tag=@idTag WHERE id = idChar;
	
    IF @hasTag > 0 THEN 
		UPDATE TagsXCharacter SET activo=1 WHERE idTag=@idTag AND idChar=idChar;
	ELSE 
		INSERT INTO TagsXCharacter VALUES(@idTag, idChar, 1);
    END IF;
	
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `registerVenta`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `registerVenta` (IN `nombre` VARCHAR(45), IN `piupoints` INT(11))  NO SQL
BEGIN
	SET @id = (SELECT idPlayer FROM Characters c WHERE c.nombre=nombre);
    START TRANSACTION;
		INSERT INTO ventasPiuPoints_accounts(idPlayer, piupoints) VALUES(@id, piupoints);
        UPDATE Players p SET p.pendingPiuPoints = p.pendingPiuPoints + piupoints WHERE id=@id;
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `registerVipById`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `registerVipById` (IN `idChar` INT, IN `fechaInicio` TIMESTAMP, IN `days` INT, IN `boost` FLOAT)  BEGIN
    SET @hasVipTest = (SELECT COUNT(*) FROM VipPrueba v WHERE 		v.idChar=idChar AND v.vencido = 0);
    START TRANSACTION;
    
    IF @hasVipTest > 0 THEN 
		UPDATE VipPrueba SET vencido = 1 WHERE idChar=idChar;
    END IF;
    
    INSERT INTO Admin(charId, fechaInicio, fechaVencimiento, boost) VALUES(idChar, fechaInicio, fechaInicio + INTERVAL days DAY, boost);
    
    UPDATE Characters SET expboost=boost WHERE id = idChar;
    
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `registerVipPrueba`$$
CREATE DEFINER=`zombie_survival`@`%` PROCEDURE `registerVipPrueba` (IN `charId` INT)  BEGIN
	SET @hasVip =(SELECT COUNT(*) FROM Admin a WHERE a.charId=charId AND vencido = 0);
    IF @hasVip = 0 THEN
	START TRANSACTION;
	INSERT INTO VipPrueba(idChar, fechaFin) VALUES(charId, current_timestamp() + INTERVAL 7 DAY);
    UPDATE Characters SET expboost=3 WHERE id=charId;
    COMMIT;
	END IF;
END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `fc_login_by_steamid`$$
CREATE DEFINER=`zombie_survival`@`%` FUNCTION `fc_login_by_steamid` (`steam_id` INT) RETURNS TINYINT(11) BEGIN
	DECLARE ret TINYINT;
	SET ret = (SELECT COUNT(*) > 0 FROM Players WHERE steamid = steam_id);
    IF(ret) THEN
		UPDATE Players SET lastLogin=current_timestamp() WHERE steamid = steam_id;
    END IF;
RETURN ret;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE IF NOT EXISTS `admin` (
  `charId` int(11) NOT NULL,
  `fechaVencimiento` datetime NOT NULL,
  `fechaInicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `vencido` tinyint(4) DEFAULT '0',
  `boost` int(11) DEFAULT '1',
  `diasAFavor` int(11) DEFAULT '0',
  `tag` int(11) DEFAULT '7',
  PRIMARY KEY (`charId`,`fechaVencimiento`),
  KEY `fk_Admin_Characters1_idx` (`charId`),
  KEY `fk_Admin_Tag_idx` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `characters`
--

DROP TABLE IF EXISTS `characters`;
CREATE TABLE IF NOT EXISTS `characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idPlayer` int(11) NOT NULL,
  `creationDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastLogin` timestamp NULL DEFAULT NULL,
  `nombre` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `piuPoints` int(11) DEFAULT '0',
  `experiencia` int(11) DEFAULT '1',
  `level` int(11) DEFAULT '1',
  `reset` int(11) DEFAULT '0',
  `expboost` float DEFAULT '1',
  `hClass` int(11) DEFAULT '0',
  `zClass` int(11) DEFAULT '0',
  `HPoints` int(11) DEFAULT '200',
  `HGPoints` int(11) DEFAULT '0',
  `ZPoints` int(11) DEFAULT '200',
  `ZGPoints` int(11) DEFAULT '0',
  `hLMHP` int(11) DEFAULT '0',
  `hCritChance` int(11) DEFAULT '0',
  `hItemChance` int(11) DEFAULT '0',
  `hAuraTime` int(11) DEFAULT '0',
  `zMadnessTime` int(11) DEFAULT '0',
  `zDamageToLM` int(11) DEFAULT '0',
  `zLeech` int(11) DEFAULT '0',
  `zMadnessChance` int(11) DEFAULT '0',
  `hDamageLevel` int(11) DEFAULT '0',
  `hResistanceLevel` int(11) DEFAULT '0',
  `hPenetrationLevel` int(11) DEFAULT '0',
  `hDexterityLevel` int(11) DEFAULT '0',
  `zDamageLevel` int(11) DEFAULT '0',
  `zResistancelevel` int(11) DEFAULT '0',
  `zDexteritylevel` int(11) DEFAULT '0',
  `zHealthLevel` int(11) DEFAULT '0',
  `primarySelected` int(11) NOT NULL DEFAULT '0',
  `secondarySelected` int(11) NOT NULL DEFAULT '0',
  `partyInv` tinyint(4) DEFAULT '1',
  `autoClass` tinyint(4) DEFAULT '1',
  `autoWeap` tinyint(4) DEFAULT '1',
  `autoGPack` tinyint(4) DEFAULT '1',
  `bullets` tinyint(4) DEFAULT '1',
  `hAlineacion` int(11) DEFAULT '0',
  `zAlineacion` int(11) DEFAULT '0',
  `gPack` int(11) DEFAULT '0',
  `hudColor` int(11) DEFAULT '0',
  `nvgColor` int(11) DEFAULT '0',
  `tag` int(11) DEFAULT '0',
  `hat` int(11) DEFAULT '0',
  `hatPoints` int(11) DEFAULT '0',
  `accessLevel` int(11) DEFAULT '2',
  `usedVipPrueba` tinyint(4) DEFAULT '0',
  `refeerCode` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idCharacters_UNIQUE` (`id`),
  UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  KEY `fk_Characters_Players_idx` (`idPlayer`),
  KEY `fk_Tag_Players_idx` (`tag`),
  KEY `fk_Hat_Players_idx` (`hat`)
) ENGINE=InnoDB AUTO_INCREMENT=30337 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estructura de tabla para la tabla `characters_renames`
--

DROP TABLE IF EXISTS `characters_renames`;
CREATE TABLE IF NOT EXISTS `characters_renames` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `old_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `new_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `piupoints_paid` int(11) NOT NULL,
  `namechange_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rename_character_id` (`character_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estructura de tabla para la tabla `hats`
--

DROP TABLE IF EXISTS `hats`;
CREATE TABLE IF NOT EXISTS `hats` (
  `idHat` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modelPath` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset` int(11) DEFAULT '0',
  `legacy` tinyint(4) DEFAULT '0',
  `order` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idHat`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `hats`
--

INSERT INTO `hats` (`idHat`, `name`, `modelPath`, `reset`, `legacy`, `order`) VALUES
(0, 'Ninguno', 'none', 0, 0, 0),
(1, 'Porcelain', 'models/player/holiday/facemasks/porcelain_doll.mdl', 52, 0, 18),
(2, 'Fortune', 'models/player/holiday/facemasks/facemask_zombie_fortune_plastic.mdl', 18, 0, 17),
(3, 'Wolf', 'models/player/holiday/facemasks/facemask_wolf.mdl', 84, 0, 16),
(4, 'Tiki', 'models/player/holiday/facemasks/facemask_tiki.mdl', 0, 1, 2),
(5, 'Skull', 'models/player/holiday/facemasks/facemask_skull.mdl', 75, 0, 14),
(6, 'Sheep', 'models/player/holiday/facemasks/facemask_sheep_model.mdl', 25, 0, 13),
(7, 'Bloody Sheep', 'models/player/holiday/facemasks/facemask_sheep_bloody.mdl', 63, 0, 12),
(8, 'Samurai', 'models/player/holiday/facemasks/facemask_samurai.mdl', 120, 0, 11),
(9, 'Pumpkin', 'models/player/holiday/facemasks/facemask_pumpkin.mdl', 0, 1, 1),
(10, 'Porcelain Kabuki', 'models/player/holiday/facemasks/facemask_porcelain_doll_kabuki.mdl', 92, 0, 10),
(11, 'Hoxton', 'models/player/holiday/facemasks/facemask_hoxton.mdl', 42, 0, 9),
(12, 'Devil', 'models/player/holiday/facemasks/facemask_devil_plastic.mdl', 3, 0, 8),
(13, 'Dallas', 'models/player/holiday/facemasks/facemask_dallas.mdl', 130, 0, 7),
(14, 'Chains', 'models/player/holiday/facemasks/facemask_chains.mdl', 33, 0, 6),
(15, 'Bunny', 'models/player/holiday/facemasks/facemask_bunny.mdl', 7, 0, 5),
(16, 'Boar', 'models/player/holiday/facemasks/facemask_boar.mdl', 1, 0, 4),
(17, 'Evil Clown', 'models/player/holiday/facemasks/evil_clown.mdl', 12, 0, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hatsxcharacter`
--

DROP TABLE IF EXISTS `hatsxcharacter`;
CREATE TABLE IF NOT EXISTS `hatsxcharacter` (
  `idHat` int(11) NOT NULL,
  `idCharacter` int(11) NOT NULL,
  `activo` tinyint(4) DEFAULT NULL,
  `costo` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idHat`,`idCharacter`),
  KEY `fk_HatsXCharacter_Character_idx` (`idCharacter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `human_clases`
--

DROP TABLE IF EXISTS `human_clases`;
CREATE TABLE IF NOT EXISTS `human_clases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) NOT NULL,
  `reset` int(11) NOT NULL,
  `health` int(11) NOT NULL,
  `armor` int(11) NOT NULL,
  `speed` float NOT NULL,
  `gravity` float NOT NULL,
  `nombre` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `arms` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tier` tinyint(4) NOT NULL,
  `orden` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `human_clases`
--

INSERT INTO `human_clases` (`id`, `level`, `reset`, `health`, `armor`, `speed`, `gravity`, `nombre`, `model`, `arms`, `tier`, `orden`) VALUES
(1, 1, 0, 100, 0, 1, 1, 'Civil', 'models/player/custom_player/kuristaja/l4d2/ellis/ellisv2.mdl', 'models/player/custom_player/kuristaja/l4d2/ellis/ellis_arms.mdl', 0, 1),
(2, 15, 0, 100, 0, 1, 1, 'Guardia', 'models/player/custom_player/kuristaja/cso2/lincoln/lincoln.mdl', 'models/player/custom_player/kuristaja/cso2/lincoln/lincoln_arms.mdl', 0, 2),
(3, 30, 0, 100, 0, 1, 1, 'Brigada', 'models/player/custom_player/kuristaja/re6/chris/chrisv4.mdl', 'models/player/custom_player/kuristaja/re6/chris/chris_arms.mdl', 0, 3),
(4, 60, 0, 100, 0, 1, 1, 'Oficial', 'models/player/custom_player/kuristaja/cso2/gign/gign.mdl', 'models/player/custom_player/kuristaja/cso2/gign/gign_arms.mdl', 0, 4),
(5, 90, 0, 100, 0, 1, 1, 'Teniente', 'models/player/custom_player/kuristaja/cso2/emma/emma.mdl', 'models/player/custom_player/kuristaja/cso2/emma/emma_arms.mdl', 0, 5),
(6, 110, 0, 100, 0, 1, 1, 'Soldado', 'models/player/custom_player/kuristaja/hunk/hunk.mdl', 'models/player/custom_player/kuristaja/hunk/hunk_arms.mdl', 0, 6),
(7, 130, 0, 100, 0, 1, 1, 'Sargento', 'models/player/custom_player/kuristaja/cso2/mila/mila.mdl', 'models/player/custom_player/kuristaja/cso2/mila/mila_arms.mdl', 0, 7),
(8, 150, 0, 100, 0, 1, 1, 'Investigadora', 'models/player/custom_player/kuristaja/cso2/carrie/carrie.mdl', 'models/player/custom_player/kuristaja/cso2/carrie/carrie_arms.mdl', 0, 8),
(9, 180, 0, 100, 0, 1, 1, 'Ricky', 'models/player/custom_player/kuristaja/cso2/karachenko/karachenko.mdl', 'models/player/custom_player/kuristaja/cso2/karachenko/karachenko_arms.mdl', 0, 9),
(10, 210, 0, 100, 0, 1, 1, 'Capitan', 'models/player/custom_player/kuristaja/cso2/707/707.mdl', 'models/player/custom_player/kuristaja/cso2/707/707_arms.mdl', 0, 10),
(11, 240, 0, 100, 0, 1, 1, 'Fuerzas Especiales', 'models/player/custom_player/kuristaja/cso2/lisa/lisa.mdl', 'models/player/custom_player/kuristaja/cso2/lisa/lisa_arms.mdl', 0, 11),
(12, 260, 0, 100, 0, 1, 1, 'Guerrera Khaz\'El', 'models/player/custom_player/hekut/talizorah/talizorah.mdl', 'models/player/custom_player/hekut/talizorah/talizorah_arms.mdl', 0, 12),
(13, 280, 10, 100, 0, 1, 1, 'Super Soldado', 'models/player/custom_player/kuristaja/nanosuit/nanosuitv3.mdl', 'models/player/custom_player/kuristaja/nanosuit/nanosuit_arms.mdl', 0, 13),
(14, 330, 20, 100, 0, 1, 1, 'Jigsaw', 'models/player/custom_player/kuristaja/billy/billy_normal.mdl', 'models/player/custom_player/kuristaja/billy/billy_arms.mdl', 0, 14),
(15, 350, 30, 100, 0, 1, 1, 'Michael Myers', 'models/player/custom_player/kuristaja/myers/myers.mdl', 'models/player/custom_player/kuristaja/myers/myers_arms.mdl', 0, 15),
(16, 360, 40, 100, 0, 1, 1, 'Freddy Krueger', 'models/player/custom_player/kuristaja/krueger/krueger.mdl', 'models/player/custom_player/kuristaja/krueger/krueger_arms2.mdl', 0, 16),
(17, 370, 50, 100, 0, 1, 1, 'Texas\' Leatherface', 'models/player/custom_player/kuristaja/leatherface/leatherface.mdl', 'models/player/custom_player/kuristaja/leatherface/leatherface_arms.mdl', 0, 17),
(18, 380, 70, 100, 0, 1, 1, 'T-600', 'models/player/custom_player/kuristaja/t-600/t-600.mdl', 'models/player/custom_player/kuristaja/t-600/t-600_arms.mdl', 0, 18);

-- --------------------------------------------------------
--
-- Estructura de tabla para la tabla `players`
--

DROP TABLE IF EXISTS `players`;
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contrasenia` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `steamid` int(11) DEFAULT NULL,
  `email` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastLogin` timestamp NULL DEFAULT NULL,
  `creationDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `blockAccess` tinyint(1) NOT NULL DEFAULT '0',
  `piupoints` int(11) NOT NULL DEFAULT '2000',
  `pendingPiuPoints` int(11) NOT NULL DEFAULT '0',
  `lastIP` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `steamid_UNIQUE` (`steamid`)
) ENGINE=InnoDB AUTO_INCREMENT=25703 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `primaryweapons`
--

DROP TABLE IF EXISTS `primaryweapons`;
CREATE TABLE IF NOT EXISTS `primaryweapons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `entity` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vModel` varchar(90) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `pModel` varchar(90) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `lvlReq` int(11) DEFAULT NULL,
  `resReq` int(11) DEFAULT NULL,
  `dmg` float DEFAULT NULL,
  `orden` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `indexOrdenWeapons` (`orden`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promo_codes`
--

DROP TABLE IF EXISTS `promo_codes`;
CREATE TABLE IF NOT EXISTS `promo_codes` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `piupoints` int(32) NOT NULL DEFAULT '0',
  `used` int(32) NOT NULL DEFAULT '0',
  `redeemer` int(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_UNIQUE` (`code`),
  KEY `fk_PromoCodes_idx` (`redeemer`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `promo_codes`
--

INSERT INTO `promo_codes` (`id`, `code`, `piupoints`, `used`, `redeemer`) VALUES
(1, 'YOURCODE-HERE', 1000000, 0, 0);

-- --------------------------------------------------------
--
-- Estructura de tabla para la tabla `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE IF NOT EXISTS `tags` (
  `idTag` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idTag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tags`
--

INSERT INTO `tags` (`idTag`, `nombre`) VALUES
(0, '[RANK]'),
(1, '[MOD]'),
(2, '[BETA-TESTER]');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tagsxcharacter`
--

DROP TABLE IF EXISTS `tagsxcharacter`;
CREATE TABLE IF NOT EXISTS `tagsxcharacter` (
  `idTag` int(11) NOT NULL,
  `idChar` int(11) NOT NULL,
  `activo` tinyint(3) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`idTag`,`idChar`),
  KEY `fk_Character_idx` (`idChar`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estructura de tabla para la tabla `ventaspiupoints`
--

DROP TABLE IF EXISTS `ventaspiupoints`;
CREATE TABLE IF NOT EXISTS `ventaspiupoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idCharacter` int(11) NOT NULL,
  `piupoints` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_ventas_Characters_idx` (`idCharacter`)
) ENGINE=InnoDB AUTO_INCREMENT=380 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estructura de tabla para la tabla `ventaspiupoints_accounts`
--

DROP TABLE IF EXISTS `ventaspiupoints_accounts`;
CREATE TABLE IF NOT EXISTS `ventaspiupoints_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idPlayer` int(11) NOT NULL,
  `piupoints` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_ventas_Accounts_idx` (`idPlayer`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vipprueba`
--

DROP TABLE IF EXISTS `vipprueba`;
CREATE TABLE IF NOT EXISTS `vipprueba` (
  `idChar` int(11) NOT NULL,
  `fechaInicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `fechaFin` datetime DEFAULT NULL,
  `vencido` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`idChar`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estructura de tabla para la tabla `zombie_clases`
--

DROP TABLE IF EXISTS `zombie_clases`;
CREATE TABLE IF NOT EXISTS `zombie_clases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) NOT NULL,
  `reset` int(11) NOT NULL,
  `health` int(11) NOT NULL,
  `damage` float NOT NULL,
  `speed` float NOT NULL,
  `gravity` float NOT NULL,
  `alpha` int(11) NOT NULL,
  `hideKnife` tinyint(1) NOT NULL,
  `nombre` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `arms` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `orden` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `zombie_clases`
--

INSERT INTO `zombie_clases` (`id`, `level`, `reset`, `health`, `damage`, `speed`, `gravity`, `alpha`, `hideKnife`, `nombre`, `model`, `arms`, `orden`) VALUES
(1, 1, 0, 200000, 1, 1.1, 1, 255, 1, 'Infectado', 'models/player/custom_player/ventoz/zombies/gozombie/gozombie_fix.mdl', 'models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl', 1),
(2, 10, 0, 205000, 1, 1.1, 1, 255, 1, 'Ex oficial', 'models/player/custom_player/ventoz/zombies/police/police_fix.mdl', 'models/zombie/normal_f/hand/hand_zombie_normal_f.mdl', 2),
(3, 30, 0, 210000, 1, 1.1, 1, 255, 1, 'Heavy Origin', 'models/player/custom_player/kodua/zombie_heavy/heavy_origin.mdl', 'models/zombie/normalhost/hand/hand_zombie_normalhost.mdl', 3),
(4, 50, 0, 215000, 1, 1.1, 1, 255, 1, 'Soldado Caido', 'models/player/custom_player/ventoz/zombies/soldado/soldado.mdl', 'models/zombie/normalhost/hand/hand_zombie_normalhost.mdl', 4),
(5, 80, 0, 220000, 1, 1.1, 1, 255, 1, 'Walker', 'models/player/custom_player/cso2_zombi/zombie_1.mdl', 'models/zombie/normal_f/hand/hand_zombie_normal_f.mdl', 5),
(6, 110, 0, 225000, 1, 1.1, 1, 255, 0, 'Simio Mutante', 'models/player/custom_player/kodua/eliminator/eliminator.mdl', 'models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl', 6),
(7, 130, 0, 230000, 1, 1.1, 1, 255, 1, 'Stalker', 'models/player/custom_player/ventoz/zombies/skinny/skinny_fix.mdl', 'models/zombie/normalhost_female/hand/hand_zombie_normalhost_f.mdl', 7),
(8, 160, 0, 235000, 1, 1.1, 1, 255, 1, 'Inferno', 'models/player/custom_player/cso2_zombi/normalhost3.mdl', 'models/zombie/normalhost/hand/hand_zombie_normalhost.mdl', 8),
(9, 190, 0, 240000, 1, 1.1, 1, 255, 1, 'Morbido', 'models/player/custom_player/kodua/bloatv2/bloat.mdl', 'models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl', 9),
(10, 220, 0, 245000, 1, 1.1, 1, 255, 1, 'Tundra', 'models/player/custom_player/kodua/bo/nazi_frozen.mdl', 'models/zombie/normal_f/hand/hand_zombie_normal_f.mdl', 10),
(11, 290, 5, 260000, 1, 1.1, 1, 255, 1, 'Creep', 'models/player/custom_player/kodua/invisible_bitch/stalker_fix.mdl', 'models/zombie/normal_f/hand/hand_zombie_normal_f.mdl', 12),
(12, 300, 10, 270000, 1, 1.1, 1, 255, 1, 'Triturador', 'models/player/custom_player/kodua/fleshpoundv2/fleshpound.mdl', 'models/zombie/normal/hand/hand_zombie_normal_fix_v2.mdl', 13),
(13, 320, 20, 280000, 1, 1.1, 1, 255, 1, 'Nightmare', 'models/player/custom_player/kodua/scrake_albino/scrake.mdl', 'models/zombie/normalhost/hand/hand_zombie_normalhost.mdl', 14),
(14, 340, 30, 290000, 1, 1.1, 1, 255, 1, 'Momia', 'models/player/custom_player/caleon1/mummy/mummy.mdl', 'models/player/custom_player/zombie/normal_m_01/hand/eminem/hand_normal_m_01.mdl', 15),
(15, 360, 50, 310000, 1, 1.1, 1, 255, 1, 'Ghoul', 'models/player/custom_player/ventoz/zombies/radiactivo/radiactivo.mdl', 'models/zombie/normalhost/hand/hand_zombie_normalhost.mdl', 17),
(16, 260, 0, 250000, 1, 1.1, 1, 255, 1, 'Spike', 'models/player/custom_player/owston/zombie/zombiep.mdl', 'models/zombie/normal_p/hand_zombiep_normal_v1.mdl', 11),
(17, 350, 40, 300000, 1, 1.1, 1, 255, 1, 'Pharaoh', 'models/player/custom_player/ventoz/god/god2.mdl', 'models/zombie/normalgod/hand/hand_zombie_normal_god.mdl', 16);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `fk_Admin_Characters1` FOREIGN KEY (`charId`) REFERENCES `characters` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Admin_Tag` FOREIGN KEY (`tag`) REFERENCES `tags` (`idTag`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Filtros para la tabla `characters`
--
ALTER TABLE `characters`
  ADD CONSTRAINT `fk_Characters_Players` FOREIGN KEY (`idPlayer`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Hat_Players` FOREIGN KEY (`hat`) REFERENCES `hats` (`idHat`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Tag_Players` FOREIGN KEY (`tag`) REFERENCES `tags` (`idTag`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `characters_renames`
--
ALTER TABLE `characters_renames`
  ADD CONSTRAINT `fk_rename_character_id` FOREIGN KEY (`character_id`) REFERENCES `characters` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `hatsxcharacter`
--
ALTER TABLE `hatsxcharacter`
  ADD CONSTRAINT `fk_HatsXCharacter_Character` FOREIGN KEY (`idCharacter`) REFERENCES `characters` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_HatsXCharacter_Hats` FOREIGN KEY (`idHat`) REFERENCES `hats` (`idHat`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `promo_codes`
--
ALTER TABLE `promo_codes`
  ADD CONSTRAINT `fk_PromoCodes_Character` FOREIGN KEY (`redeemer`) REFERENCES `characters` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tagsxcharacter`
--
ALTER TABLE `tagsxcharacter`
  ADD CONSTRAINT `fk_Characters` FOREIGN KEY (`idChar`) REFERENCES `characters` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Tags` FOREIGN KEY (`idTag`) REFERENCES `tags` (`idTag`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `ventaspiupoints`
--
ALTER TABLE `ventaspiupoints`
  ADD CONSTRAINT `fk_ventas_Characters` FOREIGN KEY (`idCharacter`) REFERENCES `characters` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `ventaspiupoints_accounts`
--
ALTER TABLE `ventaspiupoints_accounts`
  ADD CONSTRAINT `fk_Ventas_Accounts` FOREIGN KEY (`idPlayer`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
