-- MySQL dump 10.13  Distrib 9.4.0, for Win64 (x86_64)
--
-- Host: localhost    Database: graphite_db
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `dropdown_approvals`
--

DROP TABLE IF EXISTS `dropdown_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dropdown_approvals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛楁?鍚嶇О',
  `option_value` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '寰呭?鎵归?椤瑰?',
  `option_label` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '寰呭?鎵归?椤规樉绀烘枃鏈',
  `requested_by` int NOT NULL COMMENT '鐢宠?鐢ㄦ埛ID',
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT '瀹℃壒鐘舵?',
  `approved_by` int DEFAULT NULL COMMENT '瀹℃壒鐢ㄦ埛ID',
  `reason` text COLLATE utf8mb4_unicode_ci COMMENT '瀹℃壒鍘熷洜/璇存槑',
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鐢宠?鏃堕棿',
  `processed_at` timestamp NULL DEFAULT NULL COMMENT '澶勭悊鏃堕棿',
  PRIMARY KEY (`id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_field_name` (`field_name`),
  KEY `idx_status` (`status`),
  KEY `idx_requested_by` (`requested_by`),
  CONSTRAINT `dropdown_approvals_ibfk_1` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `dropdown_approvals_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='涓嬫媺閫夋嫨鏂板?瀹℃壒琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dropdown_approvals`
--

LOCK TABLES `dropdown_approvals` WRITE;
/*!40000 ALTER TABLE `dropdown_approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `dropdown_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dropdown_fields`
--

DROP TABLE IF EXISTS `dropdown_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dropdown_fields` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛楁?鍚嶇О',
  `field_label` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛楁?鏄剧ず鍚嶇О',
  `field_type` enum('fixed','expandable','searchable') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fixed' COMMENT '瀛楁?绫诲瀷锛氬浐瀹?鍙?墿灞?鍙?悳绱',
  `allow_user_add` tinyint(1) DEFAULT '0' COMMENT '鏄?惁鍏佽?鏅??鐢ㄦ埛娣诲姞閫夐」',
  `allow_engineer_add` tinyint(1) DEFAULT '1' COMMENT '鏄?惁鍏佽?宸ョ▼甯堟坊鍔犻?椤',
  `allow_admin_add` tinyint(1) DEFAULT '1' COMMENT '鏄?惁鍏佽?绠＄悊鍛樻坊鍔犻?椤',
  `require_approval` tinyint(1) DEFAULT '0' COMMENT '鏂板?閫夐」鏄?惁闇??瀹℃壒',
  `max_options` int DEFAULT NULL COMMENT '鏈?ぇ閫夐」鏁伴噺闄愬埗',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '瀛楁?璇存槑',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_name` (`field_name`),
  KEY `idx_field_type` (`field_type`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='涓嬫媺閫夋嫨瀛楁?閰嶇疆琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dropdown_fields`
--

LOCK TABLES `dropdown_fields` WRITE;
/*!40000 ALTER TABLE `dropdown_fields` DISABLE KEYS */;
INSERT INTO `dropdown_fields` VALUES (3,'customer_type','Customer Type','fixed',0,0,0,0,NULL,'Fixed options','2025-10-01 07:43:36','2025-10-01 07:43:36'),(4,'sintering_location','Sintering Location','fixed',0,0,0,0,NULL,'Fixed options','2025-10-01 07:43:36','2025-10-01 07:43:36'),(5,'material_type_for_firing','Material Type','fixed',0,0,0,0,NULL,'Fixed options','2025-10-01 07:43:36','2025-10-01 07:43:36'),(6,'rolling_method','Rolling Method','fixed',0,0,0,0,NULL,'Fixed options','2025-10-01 07:43:36','2025-10-01 07:43:36'),(7,'customer_name','Customer Name','searchable',1,1,1,0,NULL,'Searchable and can add new','2025-10-01 07:43:36','2025-10-01 07:43:36'),(8,'pi_film_thickness','PI Film Thickness','searchable',1,1,1,0,NULL,'Searchable and can add new','2025-10-01 07:43:36','2025-10-01 07:43:36'),(9,'pi_film_model','PI Film Model','searchable',1,1,1,0,NULL,'Searchable and can add new','2025-10-01 07:43:36','2025-10-01 07:43:36'),(10,'pi_manufacturer','PI Manufacturer','searchable',1,1,1,0,NULL,'Searchable and can add new','2025-10-01 07:43:36','2025-10-01 07:43:36'),(11,'pi_thickness_detail','PI Thickness Detail','searchable',1,1,1,0,NULL,'Searchable and can add new','2025-10-01 07:43:36','2025-10-01 07:43:36');
/*!40000 ALTER TABLE `dropdown_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dropdown_options`
--

DROP TABLE IF EXISTS `dropdown_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dropdown_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛楁?鍚嶇О',
  `option_value` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閫夐」鍊',
  `option_label` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閫夐」鏄剧ず鏂囨湰',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭椤哄簭',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '鏄?惁婵?椿',
  `is_system` tinyint(1) DEFAULT '0' COMMENT '鏄?惁绯荤粺鍐呯疆锛堜笉鍙?垹闄わ級',
  `created_by` int DEFAULT NULL COMMENT '鍒涘缓鐢ㄦ埛ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_field_value` (`field_name`,`option_value`),
  KEY `created_by` (`created_by`),
  KEY `idx_field_name` (`field_name`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `dropdown_options_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='涓嬫媺閫夋嫨鏁版嵁琛?紙鏀?寔鐢ㄦ埛鍔ㄦ?娣诲姞锛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dropdown_options`
--

LOCK TABLES `dropdown_options` WRITE;
/*!40000 ALTER TABLE `dropdown_options` DISABLE KEYS */;
INSERT INTO `dropdown_options` VALUES (1,'customer_type','I','I：国际客户（International）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(2,'customer_type','D','D：国内客户（Domestic）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(3,'customer_type','N','N：内部客户（Neibu）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(4,'customer_name','RD','RD/研发',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(5,'customer_name','MP','MP/量产',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(6,'customer_name','SA','SA/三星',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(7,'customer_name','HW','HW/华为',4,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(8,'customer_name','BY','BY/比亚迪',5,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(9,'customer_name','GO','GO/Google',6,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(10,'customer_name','DJ','DJ/大疆',7,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(11,'customer_name','HC','HC/汇川',8,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(12,'customer_name','MT','MT/Meta',9,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(13,'customer_name','OP','OP/OPPO',10,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(14,'customer_name','GE','GE/歌尔',11,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(15,'customer_name','AM','AM/Amazon',12,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(16,'customer_name','CY','CY/传音',13,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(17,'customer_name','LX','LX/立讯',14,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(18,'customer_name','LG','LG/LG',15,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(19,'customer_name','RY','RY/荣耀',16,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(20,'customer_name','LQ','LQ/龙旗',17,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(21,'customer_name','IN','IN/Intel',18,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(22,'customer_name','XM','XM/小米',19,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(23,'customer_name','TM','TM/天马',20,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(24,'customer_name','AP','AP/Apple',21,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(25,'customer_name','ZX','ZX/中兴',22,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(26,'customer_name','HQ','HQ/华勤',23,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(27,'customer_name','CA','CA/Canon',24,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(28,'customer_name','VI','VI/VIVO',25,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(29,'customer_name','XT','XT/小天才',26,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(30,'customer_name','QU','QU/Qualcomm',27,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(31,'customer_name','BO','BO/京东方(BOE)',28,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(32,'customer_name','LS','LS/蓝思',29,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(33,'customer_name','OT','OT/其它',30,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(34,'sintering_location','DG','DG：碳化（Dongguan） + 石墨化（Dongguan）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(35,'sintering_location','XT','XT：碳化（湘潭/Xiangtan） + 石墨化（湘潭/Xiangtan）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(36,'sintering_location','DX','DX：碳化（东莞/Dongguan） + 石墨化（湘潭/Xiangtan）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(37,'sintering_location','WF','WF：外发',4,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(38,'material_type_for_firing','R','R：卷材（Roll）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(39,'material_type_for_firing','P','P：片材（Plate）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(40,'rolling_method','IF','IF：内部平压（In-house Flat）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(41,'rolling_method','IR','IR：内部辊压（In-house Roll）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(42,'rolling_method','OF','OF：外发平压（Outsource Flat）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(43,'rolling_method','OR','OR：外发辊压（Outsource Roll）',4,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(44,'pi_film_thickness','25','25μm',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(45,'pi_film_thickness','50','50μm',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(46,'pi_film_thickness','55','55μm',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(47,'pi_film_thickness','75','75μm',4,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(48,'pi_film_thickness','100','100μm',5,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(49,'pi_film_model','GH-38','GH-38',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(50,'pi_film_model','GP-43','GP-43',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(51,'pi_film_model','THK-43','THK-43',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(52,'pi_film_model','NA-38','NA-38',4,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(53,'pi_film_model','GH-50','GH-50',5,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(54,'pi_film_model','THK-55','THK-55',6,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(55,'pi_film_model','NA-50','NA-50',7,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(56,'pi_film_model','GP-55','GP-55',8,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(57,'pi_film_model','TH5-50','TH5-50',9,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(58,'pi_film_model','NA-62','NA-62',10,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(59,'pi_film_model','GH-62','GH-62',11,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(60,'pi_film_model','TH5-62','TH5-62',12,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(61,'pi_film_model','GH-68','GH-68',13,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(62,'pi_film_model','TH5-68','TH5-68',14,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(63,'pi_film_model','GH-75','GH-75',15,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(64,'pi_film_model','THK-65','THK-65',16,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(65,'pi_film_model','THK-72','THK-72',17,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(66,'pi_film_model','GH-90','GH-90',18,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(67,'pi_film_model','TH5-75','TH5-75',19,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(68,'pi_film_model','TH5-90','TH5-90',20,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(69,'pi_film_model','GH-100','GH-100',21,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(70,'pi_film_model','GH-125','GH-125',22,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(71,'pi_film_model','TH5-100','TH5-100',23,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(72,'pi_film_model','GH-140','GH-140',24,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(73,'pi_film_model','TH5-125','TH5-125',25,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(74,'pi_film_model','GH-150','GH-150',26,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(75,'pi_film_model','TH5-140','TH5-140',27,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(76,'pi_film_model','GTS-43','GTS-43',28,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(77,'pi_film_model','TH5-150','TH5-150',29,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(78,'pi_film_model','GTS-55','GTS-55',30,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(79,'pi_film_model','THK-150','THK-150',31,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(80,'pi_film_model','GTS-160','GTS-160',32,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(81,'pi_film_model','THK-160','THK-160',33,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(82,'pi_film_model','GTS-170','GTS-170',34,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(83,'pi_film_model','THS-150','THS-150',35,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(84,'pi_film_model','GP-65','GP-65',36,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(85,'pi_film_model','THS-160','THS-160',37,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(86,'pi_film_model','GP-72','GP-72',38,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(87,'pi_film_model','GP-90','GP-90',39,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(88,'pi_film_model','GP-100','GP-100',40,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(89,'pi_film_model','GP-105','GP-105',41,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(90,'pi_film_model','GP-150','GP-150',42,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(91,'pi_manufacturer','时代','时代',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(92,'pi_manufacturer','达迈','达迈',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(93,'pi_manufacturer','欣邦','欣邦',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01');
/*!40000 ALTER TABLE `dropdown_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_basic`
--

DROP TABLE IF EXISTS `experiment_basic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_basic` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `pi_film_thickness` decimal(8,2) DEFAULT NULL COMMENT 'PI鑶滃帤搴︼紙渭m锛',
  `customer_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '瀹㈡埛绫诲瀷',
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '瀹㈡埛鍚嶇О',
  `pi_film_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'PI鑶滃瀷鍙',
  `experiment_date` date DEFAULT NULL COMMENT '瀹為獙鐢宠?鏃ユ湡',
  `sintering_location` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐑у埗鍦扮偣',
  `material_type_for_firing` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '閫佺儳鏉愭枡绫诲瀷',
  `rolling_method` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍘嬪欢鏂瑰紡',
  `experiment_group` int DEFAULT NULL COMMENT '瀹為獙缂栫粍',
  `experiment_purpose` text COLLATE utf8mb4_unicode_ci COMMENT '瀹為獙鐩?殑',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_customer_type` (`customer_type`),
  KEY `idx_customer_name` (`customer_name`),
  KEY `idx_experiment_date` (`experiment_date`),
  KEY `idx_experiment_date_customer` (`experiment_date`,`customer_type`,`customer_name`),
  FULLTEXT KEY `experiment_purpose` (`experiment_purpose`),
  CONSTRAINT `experiment_basic_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='瀹為獙璁捐?鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_basic`
--

LOCK TABLES `experiment_basic` WRITE;
/*!40000 ALTER TABLE `experiment_basic` DISABLE KEYS */;
INSERT INTO `experiment_basic` VALUES (1,1,100.00,'I','SA','TH5-100','2025-10-08','DG','R','IF',1,'sgdfsdgsd sdg的功夫','2025-10-08 04:38:55','2025-10-08 04:38:55'),(2,2,75.00,'D','HW','THK-43','2025-10-09','DG','R','IF',1,'fdsafasdf as啊撒范德萨','2025-10-09 03:38:46','2025-10-09 03:38:46'),(3,3,100.00,'I','SA','TH5-100','2025-10-08','DG','R','IF',2,'山豆根发射点风格','2025-10-09 03:40:42','2025-10-09 03:40:42'),(5,5,25.00,'I','RD','GH-38','2025-10-09','DG','R','IF',2,'放大沙发沙发','2025-10-09 04:18:58','2025-10-09 04:18:58'),(11,7,50.00,'I','RD','GH-50','2025-10-08','DG','R','IF',1,'发生大师傅大师傅撒撒旦发生范德萨','2025-10-09 05:22:59','2025-10-09 05:22:59'),(16,8,50.00,'I','SA','GH-50','2025-10-10','XT','R','IR',2,'asfdasfas fd啊的撒发生','2025-10-10 04:27:58','2025-10-10 04:27:58'),(17,11,75.00,'N','RD','GH-38','2025-10-10','DG','R','IR',8,'啊书法大赛发发撒撒发生发','2025-10-10 05:00:03','2025-10-10 05:00:03'),(18,12,75.00,'N','RD','GH-38','2025-10-10','DG','R','IR',13,'啊书法大赛发发撒撒发生发','2025-10-10 05:02:16','2025-10-10 05:02:16'),(20,13,55.00,'D','TM','THK-55','2025-10-12','DG','R','IF',1,'asfasfasf','2025-10-12 03:21:04','2025-10-12 03:21:04'),(21,14,55.00,'D','TM','THK-55','2025-10-12','DG','R','IF',2,'asfasfasf','2025-10-12 03:21:50','2025-10-12 03:21:50'),(22,15,25.00,'I','SA','GH-38','2025-10-12','DG','R','IF',1,'asfdasf','2025-10-12 04:19:41','2025-10-12 04:19:41'),(25,18,50.00,'D','BY','THK-43','2025-10-12','DG','R','IF',1,'啊发撒是否','2025-10-12 04:23:24','2025-10-12 04:23:24'),(29,19,25.00,'I','RD','GH-38','2025-10-16','DG','R','IF',2,'asfdasfa f艾弗森大师傅','2025-10-16 03:12:31','2025-10-16 03:12:31'),(31,21,25.00,'I','RD','GP-43','2025-10-17','DG','R','IF',1,'asfasfd','2025-10-16 23:24:31','2025-10-16 23:24:31'),(32,22,25.00,'I','RD','GH-38','2025-10-14','DG','R','IF',2,'asdfasfasfsdfa','2025-10-17 01:15:48','2025-10-17 01:15:48'),(33,23,25.00,'I','RD','GH-38','2025-10-20','DG','R','IF',1,'倒萨阿迪斯ADS','2025-10-20 04:42:45','2025-10-20 04:42:45'),(34,24,25.00,'I','SA','GH-38','2025-10-20','DG','R','IF',1,'FSDAASF DASF','2025-10-20 04:44:14','2025-10-20 04:44:14'),(35,25,25.00,'D','RD','GP-43','2025-10-20','DG','R','IF',1,'ASFDASFASFSA','2025-10-20 04:46:11','2025-10-20 04:46:11'),(36,26,55.00,'I','SA','THK-43','2025-10-31','DX','R','IF',1,'asfdasfasf','2025-10-31 06:00:01','2025-10-31 06:00:01'),(40,28,55.00,'N','RD','GH-150','2025-11-02','XT','R','IR',1,'内部烧制K2000样品，为客户送样建立库存','2025-11-01 18:54:01','2025-11-01 18:54:01'),(42,29,55.00,'N','RD','THK-55','2025-11-02','WF','R','IF',1,'内部研究THK55的PI膜可以达到的最大热扩散系数','2025-11-01 22:47:32','2025-11-01 22:47:32'),(46,27,50.00,'I','SA','GH-50','2025-11-02','DG','R','IF',1,'三星1700样品烧制，检验时代的50膜的发泡性和热扩散系数，以寻求最优组合','2025-11-02 04:48:01','2025-11-02 04:48:01');
/*!40000 ALTER TABLE `experiment_basic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_carbon`
--

DROP TABLE IF EXISTS `experiment_carbon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_carbon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `carbon_furnace_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲鐐夌紪鍙',
  `carbon_furnace_batch` int DEFAULT NULL COMMENT '纰冲寲鐐夋?',
  `boat_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鑸熺毧鍨嬪彿',
  `wrapping_method` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍖呰９褰㈠紡锛堝?绛?纰崇焊锛',
  `vacuum_degree` decimal(10,4) DEFAULT NULL COMMENT '鐪熺┖搴',
  `power_consumption` decimal(10,2) DEFAULT NULL COMMENT '鐢甸噺',
  `start_time` datetime DEFAULT NULL COMMENT '寮?満鏃堕棿',
  `end_time` datetime DEFAULT NULL COMMENT '鍏虫満鏃堕棿',
  `carbon_temp1` int DEFAULT NULL COMMENT '̼???¶?1(?',
  `carbon_thickness1` decimal(10,2) DEFAULT NULL COMMENT '̼??????1(??m)',
  `carbon_temp2` int DEFAULT NULL COMMENT '̼???¶?2(?',
  `carbon_thickness2` decimal(10,2) DEFAULT NULL COMMENT '̼??????2(??m)',
  `carbon_max_temp` decimal(8,2) DEFAULT NULL COMMENT '纰冲寲鏈?珮娓╁害锛堚剝锛',
  `carbon_total_time` int DEFAULT NULL COMMENT '纰冲寲鎬绘椂闀匡紙min锛',
  `carbon_film_thickness` decimal(8,2) DEFAULT NULL COMMENT '纰冲寲鑶滃帤搴︼紙渭m锛',
  `carbon_after_weight` decimal(10,3) DEFAULT NULL COMMENT '纰冲寲鍚庨噸閲忥紙kg锛',
  `carbon_yield_rate` decimal(5,2) DEFAULT NULL COMMENT '鎴愮⒊鐜囷紙%锛',
  `carbon_loading_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲瑁呰浇鏂瑰紡鐓х墖璺?緞',
  `carbon_sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲鏍峰搧鐓х墖璺?緞',
  `carbon_other_params` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲鍏跺畠鍙傛暟鏂囦欢璺?緞',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_carbon_furnace` (`carbon_furnace_number`),
  KEY `idx_carbon_max_temp` (`carbon_max_temp`),
  KEY `idx_temp_performance` (`carbon_max_temp`,`carbon_yield_rate`),
  CONSTRAINT `experiment_carbon_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='纰冲寲鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_carbon`
--

LOCK TABLES `experiment_carbon` WRITE;
/*!40000 ALTER TABLE `experiment_carbon` DISABLE KEYS */;
INSERT INTO `experiment_carbon` VALUES (1,7,'C01',1,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1,1.00,1.000,2.00,NULL,NULL,NULL,'2025-10-09 05:22:59','2025-10-09 05:22:59'),(3,8,'C01',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,1222,1.00,2.000,3.00,NULL,NULL,NULL,'2025-10-10 04:27:58','2025-10-10 04:27:58'),(4,12,'C01',4,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1222.00,122,1.00,3.000,22.00,NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(5,13,'C01',2,'','',NULL,NULL,'2025-10-08 00:00:00','2025-10-17 00:00:00',NULL,NULL,NULL,NULL,1111.00,132,2.00,2.000,2.00,NULL,NULL,NULL,'2025-10-12 03:21:04','2025-10-12 03:21:04'),(6,14,'C01',2,'','',NULL,NULL,'2025-10-08 00:00:00','2025-10-17 00:00:00',NULL,NULL,NULL,NULL,1111.00,132,2.00,2.000,2.00,NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(7,15,'sdf',2,'','',NULL,NULL,'2025-10-17 00:00:00','2025-10-24 00:00:00',NULL,NULL,NULL,NULL,1111.00,11,1.00,1.000,2.00,NULL,NULL,NULL,'2025-10-12 04:19:41','2025-10-12 04:19:41'),(10,18,'asf',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,111.00,11,11.00,2.000,2.00,NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(13,19,'撒地方',1,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,1111,11.00,11.000,98.00,NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(14,26,'C01',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,1,1.00,2.000,2.00,NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(16,28,'C01',18,'YZ9','碳纸',10.0000,112.00,'2025-11-06 00:00:00','2025-11-08 00:00:00',NULL,NULL,NULL,NULL,1100.00,800,78.00,180.000,98.00,NULL,NULL,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(17,29,'C02',14,'T11','碳纸',33.0000,122.00,'2025-11-03 00:00:00','2025-11-04 00:00:00',500,55.00,700,60.00,1200.00,1000,66.00,200.000,96.00,NULL,NULL,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(18,27,'C01',23,'DD','碳纸',2.0000,111.00,'2025-11-04 00:00:00','2025-11-05 00:00:00',500,55.00,700,60.00,900.00,1000,65.00,160.000,98.00,NULL,NULL,NULL,'2025-11-02 04:48:01','2025-11-02 04:48:01');
/*!40000 ALTER TABLE `experiment_carbon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_graphite`
--

DROP TABLE IF EXISTS `experiment_graphite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_graphite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `graphite_furnace_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鐐夌紪鍙',
  `graphite_furnace_batch` int DEFAULT NULL COMMENT '鐭冲ⅷ鍖栫倝娆',
  `graphite_start_time` datetime DEFAULT NULL COMMENT '寮?満鏃堕棿鐐',
  `graphite_end_time` datetime DEFAULT NULL COMMENT '鍏虫満鏃堕棿鐐',
  `gas_pressure` decimal(10,4) DEFAULT NULL COMMENT '姘斿帇鍊',
  `graphite_power` decimal(10,2) DEFAULT NULL COMMENT '鐢甸噺',
  `graphite_temp1` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度1',
  `graphite_thickness1` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度1',
  `graphite_temp2` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度2',
  `graphite_thickness2` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度2',
  `graphite_temp3` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度3',
  `graphite_thickness3` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度3',
  `graphite_temp4` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度4',
  `graphite_thickness4` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度4',
  `graphite_temp5` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度5',
  `graphite_thickness5` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度5',
  `graphite_temp6` decimal(8,2) DEFAULT NULL COMMENT '石墨化温度6',
  `graphite_thickness6` decimal(8,2) DEFAULT NULL COMMENT '石墨化厚度6',
  `foam_thickness` decimal(8,2) DEFAULT NULL COMMENT '鍙戞场鍘氬害锛埼糾锛',
  `graphite_max_temp` decimal(8,2) DEFAULT NULL COMMENT '鐭冲ⅷ鍖栨渶楂樻俯搴︼紙鈩冿級',
  `graphite_width` decimal(10,2) DEFAULT NULL COMMENT '鐭冲ⅷ瀹藉箙锛坢m锛',
  `shrinkage_ratio` decimal(5,2) DEFAULT NULL COMMENT '收缩比(%)',
  `graphite_total_time` int DEFAULT NULL COMMENT '鐭冲ⅷ鍖栨?鏃堕暱锛坢in锛',
  `graphite_after_weight` decimal(10,3) DEFAULT NULL COMMENT '鐭冲ⅷ鍖栧悗閲嶉噺锛坘g锛',
  `graphite_yield_rate` decimal(5,2) DEFAULT NULL COMMENT '鎴愮⒊鐜?锛堢煶澧ㄨ川閲?PI璐ㄩ噺锛',
  `graphite_loading_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栬?杞芥柟寮忕収鐗囪矾寰',
  `graphite_sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栨牱鍝佺収鐗囪矾寰',
  `graphite_min_thickness` decimal(8,2) DEFAULT NULL COMMENT '鐭冲ⅷ鍘嬪欢鏈?杽鏋侀檺锛堢煶澧ㄧ悊璁哄瘑搴?.26g/cm鲁锛',
  `graphite_other_params` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栧叾瀹冨弬鏁版枃浠惰矾寰',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_graphite_furnace` (`graphite_furnace_number`),
  KEY `idx_graphite_max_temp` (`graphite_max_temp`),
  KEY `idx_graphite_performance` (`graphite_max_temp`,`graphite_yield_rate`),
  CONSTRAINT `experiment_graphite_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鐭冲ⅷ鍖栧弬鏁拌〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_graphite`
--

LOCK TABLES `experiment_graphite` WRITE;
/*!40000 ALTER TABLE `experiment_graphite` DISABLE KEYS */;
INSERT INTO `experiment_graphite` VALUES (1,7,'G01',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1200.00,1.00,2.00,111,2.000,87.00,NULL,NULL,1.00,NULL,'2025-10-09 05:22:59','2025-10-09 05:22:59'),(3,8,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1223.00,2.00,1.00,2,2.000,2.00,NULL,NULL,NULL,NULL,'2025-10-10 04:27:58','2025-10-10 04:27:58'),(4,12,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1222.00,23.00,2.00,122,2.000,33.00,NULL,NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(5,13,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,2.00,1.00,1.00,123,2.000,88.00,NULL,NULL,NULL,NULL,'2025-10-12 03:21:04','2025-10-12 03:21:04'),(6,14,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,2.00,1.00,1.00,123,2.000,88.00,NULL,NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(7,15,'fsad',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1112.00,1.00,1.00,1,1.000,11.00,NULL,NULL,NULL,NULL,'2025-10-12 04:19:41','2025-10-12 04:19:41'),(8,18,'asfd',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1111.00,1.00,3.00,0,2.000,1.00,NULL,NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(11,19,'3呃4',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,111.00,111.00,22.00,2,1.000,2.00,NULL,NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(12,26,'SAF',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1222.00,111.00,22.00,2,1.000,22.00,NULL,NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(13,28,'G02',100,'2025-11-09 00:00:00','2025-11-12 00:00:00',22.0000,1000.00,1500.00,55.00,1700.00,50.00,1900.00,48.00,2100.00,45.00,2400.00,43.00,2800.00,40.00,40.00,2850.00,480.00,90.00,1500,170.000,99.00,NULL,NULL,11.00,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(14,29,'G04',33,'2025-11-05 00:00:00','2025-11-10 00:00:00',3.0000,100.00,1500.00,55.00,1800.00,50.00,2000.00,50.00,2100.00,45.00,2400.00,40.00,2800.00,35.00,50.00,2850.00,200.00,85.00,5000,180.000,99.00,NULL,NULL,32.00,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32');
/*!40000 ALTER TABLE `experiment_graphite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_loose`
--

DROP TABLE IF EXISTS `experiment_loose`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_loose` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `core_tube_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍗疯姱绛掔被鍨',
  `loose_gap_inner` decimal(8,2) DEFAULT NULL COMMENT '鏉惧嵎闂撮殭鍗峰唴锛埼糾锛',
  `loose_gap_middle` decimal(8,2) DEFAULT NULL COMMENT '鏉惧嵎闂撮殭鍗蜂腑锛埼糾锛',
  `loose_gap_outer` decimal(8,2) DEFAULT NULL COMMENT '鏉惧嵎闂撮殭鍗峰?锛埼糾锛',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  CONSTRAINT `experiment_loose_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鏉惧嵎鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_loose`
--

LOCK TABLES `experiment_loose` WRITE;
/*!40000 ALTER TABLE `experiment_loose` DISABLE KEYS */;
INSERT INTO `experiment_loose` VALUES (1,7,'asf',NULL,NULL,NULL,'2025-10-09 05:22:59','2025-10-09 05:22:59'),(2,12,'',NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(3,14,'',NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(4,18,'',NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(5,19,'',NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(6,26,'',NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(8,28,'内芯',22.00,35.00,50.00,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(9,29,'Y形',3.00,11.00,33.00,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(11,27,'A',33.00,33.00,32.00,'2025-11-02 04:48:01','2025-11-02 04:48:01');
/*!40000 ALTER TABLE `experiment_loose` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_pi`
--

DROP TABLE IF EXISTS `experiment_pi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_pi` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `pi_manufacturer` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'PI鑶滃巶鍟',
  `pi_thickness_detail` decimal(8,2) DEFAULT NULL COMMENT 'PI鑶滃帤搴︼紙渭m锛',
  `pi_model_detail` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'PI鑶滃瀷鍙',
  `pi_width` decimal(10,2) DEFAULT NULL COMMENT 'PI鑶滃?骞咃紙mm锛',
  `batch_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鎵规?鍙',
  `pi_weight` decimal(10,3) DEFAULT NULL COMMENT 'PI閲嶉噺锛坘g锛',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_pi_manufacturer` (`pi_manufacturer`),
  KEY `idx_batch_number` (`batch_number`),
  CONSTRAINT `experiment_pi_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PI鑶滃弬鏁拌〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_pi`
--

LOCK TABLES `experiment_pi` WRITE;
/*!40000 ALTER TABLE `experiment_pi` DISABLE KEYS */;
INSERT INTO `experiment_pi` VALUES (1,7,'时代',25.00,'GH-38',1.00,'',NULL,'2025-10-09 05:22:59','2025-10-09 05:22:59'),(4,8,'时代',25.00,'GH-38',NULL,'',NULL,'2025-10-10 04:27:58','2025-10-10 04:27:58'),(5,12,'时代',25.00,'GP-43',NULL,'',2.000,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(6,13,'时代',25.00,'GH-38',NULL,'',2.000,'2025-10-12 03:21:04','2025-10-12 03:21:04'),(7,14,'时代',25.00,'GH-38',NULL,'',2.000,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(8,15,'时代',25.00,'GH-38',NULL,'',1.000,'2025-10-12 04:19:41','2025-10-12 04:19:41'),(9,18,'时代',25.00,'GH-38',NULL,'',1.000,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(12,19,'时代',25.00,'GH-38',NULL,'',2.000,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(14,26,'达迈',55.00,'THK-43',NULL,'',2.000,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(17,28,'时代',55.00,'THK-55',500.00,'afjalj2345435r',100.000,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(18,29,'达迈',55.00,'THK-55',555.00,'asf3343',222.000,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(22,27,'时代',50.00,'THK-43',350.00,'asdfjk87uwqri4',222.000,'2025-11-02 04:48:01','2025-11-02 04:48:01');
/*!40000 ALTER TABLE `experiment_pi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_product`
--

DROP TABLE IF EXISTS `experiment_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `product_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鎴愬搧缂栫爜',
  `avg_thickness` decimal(8,2) DEFAULT NULL COMMENT '鏍峰搧骞冲潎鍘氬害锛埼糾锛',
  `specification` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '瑙勬牸锛堝?骞卪m脳闀縨锛',
  `avg_density` decimal(6,3) DEFAULT NULL COMMENT '骞冲潎瀵嗗害锛坓/cm鲁锛',
  `thermal_diffusivity` decimal(10,6) DEFAULT NULL COMMENT '鐑?墿鏁ｇ郴鏁帮紙mm虏/s锛',
  `thermal_conductivity` decimal(8,3) DEFAULT NULL COMMENT '瀵肩儹绯绘暟k锛圵/m*k锛',
  `specific_heat` decimal(8,4) DEFAULT NULL COMMENT '姣旂儹锛圝/g/K锛',
  `cohesion` decimal(8,2) DEFAULT NULL COMMENT '鍐呰仛鍔涳紙gf锛',
  `peel_strength` decimal(8,2) DEFAULT NULL COMMENT '鍓ョ?鍔涳紙gf锛',
  `roughness` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '绮楃硻搴',
  `appearance_desc` text COLLATE utf8mb4_unicode_ci COMMENT '澶栬?鍙婁笉鑹?儏鍐垫弿杩',
  `appearance_defect_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '澶栬?涓嶈壇鐓х墖璺?緞',
  `sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鏍峰搧鐓х墖璺?緞',
  `experiment_summary` text COLLATE utf8mb4_unicode_ci COMMENT '瀹為獙鎬荤粨',
  `other_files` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍏跺畠鏂囦欢璺?緞',
  `remarks` text COLLATE utf8mb4_unicode_ci COMMENT '澶囨敞',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_product_code` (`product_code`),
  KEY `idx_avg_density` (`avg_density`),
  KEY `idx_thermal_conductivity` (`thermal_conductivity`),
  KEY `idx_product_quality` (`avg_density`,`thermal_conductivity`),
  FULLTEXT KEY `appearance_desc` (`appearance_desc`,`experiment_summary`),
  CONSTRAINT `experiment_product_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鎴愬搧鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_product`
--

LOCK TABLES `experiment_product` WRITE;
/*!40000 ALTER TABLE `experiment_product` DISABLE KEYS */;
INSERT INTO `experiment_product` VALUES (1,7,'',2.00,'100 X20',2.000,2.000000,1200.000,2.0000,2.00,2.00,'ASF','ASFDASFD',NULL,NULL,'asfdasdSAFDAS DSFD',NULL,'','2025-10-09 05:22:59','2025-10-09 05:22:59'),(2,8,'ASFSADF',1.00,'100X23',1.000,2.000000,1222.000,2.0000,2.00,2.00,'ASF','ASFDASF',NULL,NULL,'ASFDASF',NULL,'SAF','2025-10-10 04:27:58','2025-10-10 04:27:58'),(3,12,'',2.00,'100 X20',2.000,2.000000,2.000,2.0000,2.00,2.00,'SF','ASFDASFAS',NULL,NULL,'ASFASF 第三方',NULL,'SAFDASF','2025-10-10 05:02:16','2025-10-10 05:02:16'),(4,13,'',2.00,'100',1.000,2.000000,2.000,2.0000,2.00,1.00,'asfd','啊书法大赛发',NULL,NULL,'afasf asfafs',NULL,'safasf','2025-10-12 03:21:04','2025-10-12 03:21:04'),(5,14,'',2.00,'100',1.000,2.000000,2.000,2.0000,2.00,1.00,'asfd','啊书法大赛发',NULL,NULL,'afasf asfafs',NULL,'safasf','2025-10-12 03:21:50','2025-10-12 03:21:50'),(6,15,'',1.00,'111',2.000,1.000000,1.000,1.0000,1.00,1.00,'sfa','asf',NULL,NULL,'asfasfasf',NULL,'asf','2025-10-12 04:19:41','2025-10-12 04:19:41'),(7,18,'',2.00,'111',2.000,2.000000,1.000,1.0000,1.00,1.00,'sfd','asdfasfd',NULL,NULL,'asdfasfasfdas',NULL,'afsdasf','2025-10-12 04:23:24','2025-10-12 04:23:24'),(9,19,'',2.00,'11',2.000,11.000000,2.000,111.0000,2.00,1.00,'阿斯弗','啊沙发上',NULL,NULL,'艾弗森dasf',NULL,'afsas','2025-10-16 03:12:31','2025-10-16 03:12:31'),(10,26,'',2.00,'AAA',1.000,1.000000,1.000,1.0000,1.00,1.00,'ASFD','ASFASFASASF',NULL,NULL,'AFSDASFASFASFSA',NULL,'','2025-10-31 06:00:01','2025-10-31 06:00:01'),(11,28,'8798234',38.00,'480 x 30',2.213,1055.000000,1680.000,0.8500,60.00,15.00,'光滑','外观良好，部分闪电纹和凸点',NULL,NULL,'本次实验达成了实验目的，导热系数可以满足客户要求，计划下一步提供石墨化温度，继续提升K值',NULL,'无','2025-11-01 18:54:01','2025-11-01 18:54:01'),(12,29,'YASIFJ2323423',38.00,'100 X30',2.334,1068.000000,1700.000,8.5000,60.00,3.00,'正常','外观不良，大量闪电纹',NULL,NULL,'外观不良严重，需要和供应商确认重新取得材料烧制',NULL,'','2025-11-01 22:47:32','2025-11-01 22:47:32');
/*!40000 ALTER TABLE `experiment_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiment_rolling`
--

DROP TABLE IF EXISTS `experiment_rolling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiment_rolling` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `rolling_machine` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍘嬪欢鏈哄彴',
  `rolling_pressure` decimal(8,2) DEFAULT NULL COMMENT '鍘嬪欢鍘嬪姏锛圡Pa锛',
  `rolling_tension` decimal(8,2) DEFAULT NULL COMMENT '鍘嬪欢寮犲姏',
  `rolling_speed` decimal(8,3) DEFAULT NULL COMMENT '鍘嬪欢閫熷害锛坢/s锛',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  CONSTRAINT `experiment_rolling_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鍘嬪欢鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_rolling`
--

LOCK TABLES `experiment_rolling` WRITE;
/*!40000 ALTER TABLE `experiment_rolling` DISABLE KEYS */;
INSERT INTO `experiment_rolling` VALUES (1,7,'Y01',NULL,NULL,NULL,'2025-10-09 05:22:59','2025-10-09 05:22:59'),(2,12,'',NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(3,14,'',NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(4,18,'',NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(5,19,'',NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(6,26,'',NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(7,28,'Y02',2.00,5.00,100.000,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(8,29,'Y01',2.00,12.00,100.000,'2025-11-01 22:47:32','2025-11-01 22:47:32');
/*!40000 ALTER TABLE `experiment_rolling` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀹為獙缂栫爜锛堝敮涓?爣璇嗭級',
  `status` enum('draft','submitted','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft' COMMENT '鐘舵?锛氳崏绋?宸叉彁浜?瀹屾垚',
  `created_by` int NOT NULL COMMENT '鍒涘缓浜篒D',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `submitted_at` timestamp NULL DEFAULT NULL COMMENT '鎻愪氦鏃堕棿',
  `version` int DEFAULT '1' COMMENT '鐗堟湰鍙',
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT '澶囨敞淇℃伅',
  PRIMARY KEY (`id`),
  UNIQUE KEY `experiment_code` (`experiment_code`),
  KEY `idx_experiment_code` (`experiment_code`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `experiments_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='瀹為獙涓昏〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiments`
--

LOCK TABLES `experiments` WRITE;
/*!40000 ALTER TABLE `experiments` DISABLE KEYS */;
INSERT INTO `experiments` VALUES (1,'100ISA-TH5100-251008DG-RIF01','draft',1,'2025-10-08 04:38:55','2025-10-08 04:38:55',NULL,1,''),(2,'75DHW-THK43-251009DG-RIF01','draft',1,'2025-10-09 03:38:45','2025-10-09 03:38:45',NULL,1,''),(3,'100ISA-TH5100-251008DG-RIF02','draft',1,'2025-10-09 03:40:42','2025-10-09 03:40:42',NULL,1,''),(5,'25IRD-GH38-251009DG-ROF02','draft',1,'2025-10-09 04:18:58','2025-10-09 04:19:08',NULL,1,''),(7,'50IRD-GH50-251008DG-RIF01','draft',1,'2025-10-09 05:21:19','2025-10-09 05:22:59',NULL,1,''),(8,'50ISA-GH50-251010XT-RIR02','draft',1,'2025-10-10 04:25:59','2025-10-10 04:27:58',NULL,1,''),(11,'75NRD-GH38-251010DG-RIR08','draft',1,'2025-10-10 05:00:03','2025-10-10 05:00:03',NULL,1,''),(12,'75NRD-GH38-251010DG-RIR13','submitted',1,'2025-10-10 05:02:16','2025-10-10 05:02:16','2025-10-10 05:02:16',1,''),(13,'55DTM-THK55-251012DG-RIF01','draft',1,'2025-10-12 03:19:21','2025-10-12 03:21:04',NULL,1,''),(14,'55DTM-THK55-251012DG-RIF02','submitted',1,'2025-10-12 03:21:50','2025-10-12 03:21:50','2025-10-12 03:21:50',1,''),(15,'25ISA-GH38-251012DG-RIF01','draft',1,'2025-10-12 04:19:41','2025-10-12 04:19:41',NULL,1,''),(18,'50DBY-THK43-251012DG-RIF01','submitted',1,'2025-10-12 04:23:24','2025-10-12 04:23:24','2025-10-12 04:23:24',1,''),(19,'25IRD-GH38-251016DG-RIF02','submitted',1,'2025-10-16 03:10:53','2025-10-16 03:12:31','2025-10-16 11:12:31',1,''),(21,'25IRD-GP43-251017DG-RIF01','draft',1,'2025-10-16 23:24:31','2025-10-16 23:24:31',NULL,1,''),(22,'25IRD-GH38-251014DG-RIF02','draft',1,'2025-10-17 01:15:48','2025-10-17 01:15:48',NULL,1,''),(23,'25IRD-GH38-251020DG-RIF01','draft',1,'2025-10-20 04:42:45','2025-10-20 04:42:45',NULL,1,''),(24,'25ISA-GH38-251020DG-RIF01','draft',1,'2025-10-20 04:44:14','2025-10-20 04:44:14',NULL,1,''),(25,'25DRD-GP43-251020DG-RIF01','draft',1,'2025-10-20 04:46:11','2025-10-20 04:46:11',NULL,1,''),(26,'55ISA-THK43-251031DX-RIF01','submitted',1,'2025-10-31 06:00:01','2025-10-31 06:00:01','2025-10-31 14:00:01',1,NULL),(27,'50ISA-GH50-251102DG-RIF01','draft',1,'2025-11-01 18:39:23','2025-11-02 04:48:01',NULL,1,''),(28,'55NRD-GH150-251102XT-RIR01','submitted',1,'2025-11-01 18:41:11','2025-11-01 18:54:01','2025-11-02 02:54:01',1,''),(29,'55NRD-THK55-251102WF-RIF01','submitted',1,'2025-11-01 22:41:35','2025-11-01 22:47:32','2025-11-02 06:47:32',1,'');
/*!40000 ALTER TABLE `experiments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_uploads`
--

DROP TABLE IF EXISTS `file_uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_uploads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL COMMENT '瀹為獙ID',
  `field_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛楁?鍚嶇О',
  `original_filename` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍘熷?鏂囦欢鍚',
  `saved_filename` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '淇濆瓨鐨勬枃浠跺悕',
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鏂囦欢璺?緞',
  `file_size` int DEFAULT NULL COMMENT '鏂囦欢澶у皬锛堝瓧鑺傦級',
  `file_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鏂囦欢绫诲瀷',
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'MIME绫诲瀷',
  `uploaded_by` int NOT NULL COMMENT '涓婁紶鐢ㄦ埛ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '涓婁紶鏃堕棿',
  PRIMARY KEY (`id`),
  KEY `idx_experiment_id` (`experiment_id`),
  KEY `idx_field_name` (`field_name`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  CONSTRAINT `file_uploads_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_uploads_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鏂囦欢涓婁紶璁板綍琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_uploads`
--

LOCK TABLES `file_uploads` WRITE;
/*!40000 ALTER TABLE `file_uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL COMMENT '鎿嶄綔鐢ㄦ埛ID',
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鎿嶄綔绫诲瀷',
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐩?爣绫诲瀷锛坋xperiment/user绛夛級',
  `target_id` int DEFAULT NULL COMMENT '鐩?爣ID',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '鎿嶄綔鎻忚堪',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP鍦板潃',
  `user_agent` text COLLATE utf8mb4_unicode_ci COMMENT '鐢ㄦ埛浠ｇ悊',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鎿嶄綔鏃堕棿',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='绯荤粺鎿嶄綔鏃ュ織琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
INSERT INTO `system_logs` VALUES (1,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6328','2025-09-22 05:30:49'),(2,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-01 00:55:27'),(3,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6328','2025-10-07 00:31:53'),(4,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 00:47:18'),(5,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 05:46:59'),(6,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 07:02:43'),(7,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 17:29:39'),(8,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 02:52:24'),(9,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 03:34:31'),(10,1,'save_draft','experiment',1,'保存草稿 100ISA-TH5100-251008DG-RIF01','127.0.0.1',NULL,'2025-10-08 04:38:55'),(11,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 03:38:24'),(12,1,'save_draft','experiment',2,'保存草稿 75DHW-THK43-251009DG-RIF01','127.0.0.1',NULL,'2025-10-09 03:38:46'),(13,1,'save_draft','experiment',3,'保存草稿 100ISA-TH5100-251008DG-RIF02','127.0.0.1',NULL,'2025-10-09 03:40:42'),(14,1,'save_draft','experiment',4,'保存草稿 25IRD-GH38-251009DG-RIF01','127.0.0.1',NULL,'2025-10-09 03:52:10'),(15,1,'save_draft','experiment',5,'保存草稿 25IRD-GH38-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:18:58'),(16,1,'update_draft','experiment',5,'更新草稿 25IRD-GH38-251009DG-ROF02','127.0.0.1',NULL,'2025-10-09 04:19:08'),(17,1,'save_draft','experiment',6,'保存草稿 75ISA-GH75-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:46:47'),(18,1,'update_draft','experiment',6,'更新草稿 50ISA-NA50-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:47:20'),(19,1,'update_draft','experiment',6,'更新草稿 50ISA-NA50-251009DG-ROF02','127.0.0.1',NULL,'2025-10-09 04:47:32'),(20,1,'save_draft','experiment',7,'保存草稿 25IRD-GP43-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:21:19'),(21,1,'update_draft','experiment',7,'更新草稿 50IRD-GH50-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:21:31'),(22,1,'update_draft','experiment',7,'更新草稿 50IRD-GH50-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:22:59'),(23,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 04:25:17'),(24,1,'save_draft','experiment',8,'保存草稿 50ISA-GH50-251010DG-RIF02','127.0.0.1',NULL,'2025-10-10 04:25:59'),(25,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:26:17'),(26,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:26:28'),(27,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:27:18'),(28,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:27:58'),(29,1,'save_draft','experiment',11,'保存草稿 75NRD-GH38-251010DG-RIR08','127.0.0.1',NULL,'2025-10-10 05:00:03'),(30,1,'submit_experiment','experiment',12,'提交实验 75NRD-GH38-251010DG-RIR13','127.0.0.1',NULL,'2025-10-10 05:02:16'),(31,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 03:18:46'),(32,1,'save_draft','experiment',13,'保存草稿 55DTM-THK55-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 03:19:21'),(33,1,'update_draft','experiment',13,'更新草稿 55DTM-THK55-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 03:21:04'),(34,1,'submit_experiment','experiment',14,'提交实验 55DTM-THK55-251012DG-RIF02','127.0.0.1',NULL,'2025-10-12 03:21:50'),(35,1,'save_draft','experiment',15,'保存草稿 25ISA-GH38-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 04:19:41'),(36,1,'submit_experiment','experiment',18,'提交实验 50DBY-THK43-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 04:23:24'),(37,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-14 00:30:32'),(38,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:01:35'),(39,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:15'),(40,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:28'),(41,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:44'),(42,1,'save_draft','experiment',19,'保存草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:10:53'),(43,1,'update_draft','experiment',19,'更新草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:11:52'),(44,1,'update_draft','experiment',19,'更新草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:12:22'),(45,1,'submit_experiment','experiment',19,'提交实验 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:12:31'),(46,1,'save_draft','experiment',20,'保存草稿 25IMP-GH38-251016DG-RIF01','127.0.0.1',NULL,'2025-10-16 04:30:49'),(47,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 21:43:26'),(48,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 21:44:14'),(49,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 21:44:51'),(50,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 23:22:27'),(51,1,'save_draft','experiment',21,'保存草稿 25IRD-GP43-251017DG-RIF01','127.0.0.1',NULL,'2025-10-16 23:24:31'),(52,1,'save_draft','experiment',22,'保存草稿 25IRD-GH38-251014DG-RIF02','127.0.0.1',NULL,'2025-10-17 01:15:48'),(53,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-20 04:29:23'),(54,1,'save_draft','experiment',23,'保存草稿 25IRD-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:42:45'),(55,1,'save_draft','experiment',24,'保存草稿 25ISA-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:44:14'),(56,1,'save_draft','experiment',25,'保存草稿 25DRD-GP43-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:46:11'),(57,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-20 05:38:25'),(58,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-21 05:15:05'),(59,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 02:14:51'),(60,1,'delete_experiment','experiment',20,'删除实验 25IMP-GH38-251016DG-RIF01','127.0.0.1',NULL,'2025-10-27 02:15:18'),(61,1,'delete_experiment','experiment',6,'删除实验 50ISA-NA50-251009DG-ROF02','127.0.0.1',NULL,'2025-10-27 02:41:13'),(62,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 03:20:01'),(63,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 03:27:11'),(64,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 02:50:59'),(65,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 02:51:08'),(66,1,'delete_experiment','experiment',4,'删除实验 25IRD-GH38-251009DG-RIF01','127.0.0.1',NULL,'2025-10-28 02:51:48'),(67,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 03:59:18'),(68,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 21:41:50'),(69,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-29 22:57:49'),(70,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-31 05:54:30'),(71,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-31 05:57:45'),(72,1,'submit_experiment','experiment',26,'提交实验 55ISA-THK43-251031DX-RIF01','127.0.0.1',NULL,'2025-10-31 06:00:01'),(73,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 06:37:16'),(74,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 06:37:24'),(75,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 18:25:16'),(76,1,'save_draft','experiment',27,'保存草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-01 18:39:23'),(77,1,'save_draft','experiment',28,'保存草稿 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:41:11'),(78,1,'update_draft','experiment',28,'更新草稿 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:44:01'),(79,1,'submit_experiment','experiment',28,'提交实验 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:54:01'),(80,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 22:35:03'),(81,1,'save_draft','experiment',29,'保存草稿 55NRD-THK55-251102WF-RIF01','127.0.0.1',NULL,'2025-11-01 22:41:35'),(82,1,'submit_experiment','experiment',29,'提交实验 55NRD-THK55-251102WF-RIF01','127.0.0.1',NULL,'2025-11-01 22:47:32'),(83,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-02 00:38:49'),(84,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:45:43'),(85,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:46:32'),(86,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:46:46'),(87,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:48:01'),(88,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-03 05:29:11'),(89,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-06 00:16:44'),(90,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-06 00:40:57'),(91,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 19:25:58'),(92,NULL,'login_failed',NULL,NULL,'用户 engineer 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 21:44:12'),(93,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 21:44:23'),(94,NULL,'login_failed',NULL,NULL,'用户 engineer  登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:29'),(95,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:38'),(96,NULL,'login_failed',NULL,NULL,'用户 user 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:53'),(97,NULL,'login_failed',NULL,NULL,'用户 user 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:51:39'),(98,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 03:44:43'),(99,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:16:50'),(100,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:31:53'),(101,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:07'),(102,5,'login_failed',NULL,NULL,'用户 user 登录失败 - 密码错误','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:23'),(103,5,'login_success',NULL,NULL,'用户 user 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:31'),(104,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:49:28');
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀵嗙爜鍝堝笇',
  `role` enum('admin','engineer','user') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user' COMMENT '鐢ㄦ埛瑙掕壊锛氱?鐞嗗憳/宸ョ▼甯?鐢ㄦ埛',
  `real_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '閭??',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '鏄?惁婵?椿',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `last_login` timestamp NULL DEFAULT NULL COMMENT '鏈?悗鐧诲綍鏃堕棿',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鐢ㄦ埛琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2b$12$PduedbgBhaGHueQIr6DcpuB2QsZkjlXDr5hxZUKVay/Gphpedvwne','admin','系统管理员','admin@example.com',1,'2025-09-21 12:06:49','2025-11-21 04:49:28','2025-11-21 04:49:28'),(4,'engineer','$2b$12$HqnDExz3sSLcdZYDjzQcYe1XZ23eSKLsHevMz7XvfIYsFzZXsdnn2','engineer','工程师','engineer@example.com',1,'2025-11-21 12:38:43','2025-11-21 04:41:07','2025-11-21 04:41:07'),(5,'user','$2b$12$.7vLygHOilBvt9Nh7ELRuO2yvPzWxOU9Ay8NV0cxY0M0sLDLlC9ZK','user','普通用户','user@example.com',1,'2025-11-21 12:38:43','2025-11-21 04:41:31','2025-11-21 04:41:31');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_experiment_full`
--

DROP TABLE IF EXISTS `v_experiment_full`;
/*!50001 DROP VIEW IF EXISTS `v_experiment_full`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_experiment_full` AS SELECT 
 1 AS `id`,
 1 AS `experiment_code`,
 1 AS `status`,
 1 AS `created_by`,
 1 AS `created_by_name`,
 1 AS `created_by_real_name`,
 1 AS `created_at`,
 1 AS `updated_at`,
 1 AS `submitted_at`,
 1 AS `pi_film_thickness`,
 1 AS `customer_type`,
 1 AS `customer_name`,
 1 AS `pi_film_model`,
 1 AS `experiment_date`,
 1 AS `sintering_location`,
 1 AS `material_type_for_firing`,
 1 AS `rolling_method`,
 1 AS `experiment_group`,
 1 AS `experiment_purpose`,
 1 AS `pi_manufacturer`,
 1 AS `pi_width`,
 1 AS `batch_number`,
 1 AS `pi_weight`,
 1 AS `carbon_max_temp`,
 1 AS `carbon_total_time`,
 1 AS `carbon_yield_rate`,
 1 AS `graphite_max_temp`,
 1 AS `graphite_total_time`,
 1 AS `graphite_yield_rate`,
 1 AS `shrinkage_ratio`,
 1 AS `avg_thickness`,
 1 AS `avg_density`,
 1 AS `thermal_conductivity`,
 1 AS `cohesion`,
 1 AS `peel_strength`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'graphite_db'
--

--
-- Dumping routines for database 'graphite_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `GenerateExperimentCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = gbk */ ;
/*!50003 SET character_set_results = gbk */ ;
/*!50003 SET collation_connection  = gbk_chinese_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateExperimentCode`(
    IN p_pi_thickness DECIMAL(8,2),
    IN p_customer_type VARCHAR(20),
    IN p_customer_name VARCHAR(100),
    IN p_pi_model VARCHAR(100),
    IN p_experiment_date DATE,
    IN p_sintering_location VARCHAR(50),
    IN p_material_type VARCHAR(20),
    IN p_rolling_method VARCHAR(20),
    IN p_experiment_group INT,
    OUT p_experiment_code VARCHAR(50)
)
BEGIN
    DECLARE customer_code VARCHAR(10);
    DECLARE date_part VARCHAR(6);
    
    -- 提取客户代码（取/前的部分）
    SET customer_code = SUBSTRING_INDEX(p_customer_name, '/', 1);
    
    -- 格式化日期（取后6位）
    SET date_part = RIGHT(REPLACE(p_experiment_date, '-', ''), 6);
    
    -- 生成实验编码
    SET p_experiment_code = CONCAT(
        CAST(p_pi_thickness AS CHAR),          -- PI膜厚度
        p_customer_type,                        -- 客户类型首字母
        customer_code,                          -- 客户代码
        '-',
        p_pi_model,                            -- PI膜型号
        '-',
        date_part,                             -- 日期后6位
        p_sintering_location,                  -- 烧制地点
        '-',
        p_material_type,                       -- 材料类型
        p_rolling_method,                      -- 压延方式
        LPAD(p_experiment_group, 2, '0')      -- 实验编组（补零到2位）
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_experiment_full`
--

/*!50001 DROP VIEW IF EXISTS `v_experiment_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = gbk */;
/*!50001 SET character_set_results     = gbk */;
/*!50001 SET collation_connection      = gbk_chinese_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_experiment_full` AS select `e`.`id` AS `id`,`e`.`experiment_code` AS `experiment_code`,`e`.`status` AS `status`,`e`.`created_by` AS `created_by`,`u`.`username` AS `created_by_name`,`u`.`real_name` AS `created_by_real_name`,`e`.`created_at` AS `created_at`,`e`.`updated_at` AS `updated_at`,`e`.`submitted_at` AS `submitted_at`,`eb`.`pi_film_thickness` AS `pi_film_thickness`,`eb`.`customer_type` AS `customer_type`,`eb`.`customer_name` AS `customer_name`,`eb`.`pi_film_model` AS `pi_film_model`,`eb`.`experiment_date` AS `experiment_date`,`eb`.`sintering_location` AS `sintering_location`,`eb`.`material_type_for_firing` AS `material_type_for_firing`,`eb`.`rolling_method` AS `rolling_method`,`eb`.`experiment_group` AS `experiment_group`,`eb`.`experiment_purpose` AS `experiment_purpose`,`ep`.`pi_manufacturer` AS `pi_manufacturer`,`ep`.`pi_width` AS `pi_width`,`ep`.`batch_number` AS `batch_number`,`ep`.`pi_weight` AS `pi_weight`,`ec`.`carbon_max_temp` AS `carbon_max_temp`,`ec`.`carbon_total_time` AS `carbon_total_time`,`ec`.`carbon_yield_rate` AS `carbon_yield_rate`,`eg`.`graphite_max_temp` AS `graphite_max_temp`,`eg`.`graphite_total_time` AS `graphite_total_time`,`eg`.`graphite_yield_rate` AS `graphite_yield_rate`,`eg`.`shrinkage_ratio` AS `shrinkage_ratio`,`epd`.`avg_thickness` AS `avg_thickness`,`epd`.`avg_density` AS `avg_density`,`epd`.`thermal_conductivity` AS `thermal_conductivity`,`epd`.`cohesion` AS `cohesion`,`epd`.`peel_strength` AS `peel_strength` from ((((((`experiments` `e` left join `users` `u` on((`e`.`created_by` = `u`.`id`))) left join `experiment_basic` `eb` on((`e`.`id` = `eb`.`experiment_id`))) left join `experiment_pi` `ep` on((`e`.`id` = `ep`.`experiment_id`))) left join `experiment_carbon` `ec` on((`e`.`id` = `ec`.`experiment_id`))) left join `experiment_graphite` `eg` on((`e`.`id` = `eg`.`experiment_id`))) left join `experiment_product` `epd` on((`e`.`id` = `epd`.`experiment_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-23 14:54:13
