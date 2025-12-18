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
-- Table structure for table `backup_tasks`
--

DROP TABLE IF EXISTS `backup_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backup_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` varchar(50) NOT NULL COMMENT '浠诲姟鍞?竴鏍囪瘑',
  `filename` varchar(255) NOT NULL COMMENT '澶囦唤鏂囦欢鍚',
  `status` enum('pending','running','success','failed') DEFAULT 'pending' COMMENT '浠诲姟鐘舵?',
  `file_size` bigint DEFAULT '0' COMMENT '鏂囦欢澶у皬锛堝瓧鑺傦級',
  `error_message` text COMMENT '閿欒?淇℃伅',
  `created_by` int NOT NULL COMMENT '鍒涘缓鑰匢D',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `started_at` timestamp NULL DEFAULT NULL COMMENT '寮??鎵ц?鏃堕棿',
  `completed_at` timestamp NULL DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_id` (`task_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `backup_tasks_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鏁版嵁搴撳?浠戒换鍔¤〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_tasks`
--

LOCK TABLES `backup_tasks` WRITE;
/*!40000 ALTER TABLE `backup_tasks` DISABLE KEYS */;
INSERT INTO `backup_tasks` VALUES (1,'24af9542-cf50-4c05-becd-acec7b34d6b8','graphite_backup_20251216_215243.sql','failed',0,'No module named \'config\'',1,'2025-12-16 05:52:43','2025-12-16 05:52:43','2025-12-16 05:52:43'),(2,'08b4a8c1-3163-42ca-921b-353070865787','graphite_backup_20251216_221810.sql','running',0,NULL,1,'2025-12-16 06:18:11','2025-12-16 06:18:11',NULL);
/*!40000 ALTER TABLE `backup_tasks` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='涓嬫媺閫夋嫨鏁版嵁琛?紙鏀?寔鐢ㄦ埛鍔ㄦ?娣诲姞锛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dropdown_options`
--

LOCK TABLES `dropdown_options` WRITE;
/*!40000 ALTER TABLE `dropdown_options` DISABLE KEYS */;
INSERT INTO `dropdown_options` VALUES (1,'customer_type','I','I：国际客户（International）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(2,'customer_type','D','D：国内客户（Domestic）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(3,'customer_type','N','N：内部客户（Neibu）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(4,'customer_name','RD','RD/研发',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(5,'customer_name','MP','MP/量产',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(6,'customer_name','SA','SA/三星',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(7,'customer_name','HW','HW/华为',4,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(8,'customer_name','BY','BY/比亚迪',5,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(9,'customer_name','GO','GO/Google',6,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(10,'customer_name','DJ','DJ/大疆',7,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(11,'customer_name','HC','HC/汇川',8,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(12,'customer_name','MT','MT/Meta',9,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(13,'customer_name','OP','OP/OPPO',10,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(14,'customer_name','GE','GE/歌尔',11,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(15,'customer_name','AM','AM/Amazon',12,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(16,'customer_name','CY','CY/传音',13,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(17,'customer_name','LX','LX/立讯',14,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(18,'customer_name','LG','LG/LG',15,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(19,'customer_name','RY','RY/荣耀',16,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(20,'customer_name','LQ','LQ/龙旗',17,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(21,'customer_name','IN','IN/Intel',18,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(22,'customer_name','XM','XM/小米',19,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(23,'customer_name','TM','TM/天马',20,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(24,'customer_name','AP','AP/Apple',21,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(25,'customer_name','ZX','ZX/中兴',22,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(26,'customer_name','HQ','HQ/华勤',23,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(27,'customer_name','CA','CA/Canon',24,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(28,'customer_name','VI','VI/VIVO',25,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(29,'customer_name','XT','XT/小天才',26,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(30,'customer_name','QU','QU/Qualcomm',27,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(31,'customer_name','BO','BO/京东方(BOE)',28,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(32,'customer_name','LS','LS/蓝思',29,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(33,'customer_name','OT','OT/其它',30,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(34,'sintering_location','DG','DG：碳化（Dongguan） + 石墨化（Dongguan）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(35,'sintering_location','XT','XT：碳化（湘潭/Xiangtan） + 石墨化（湘潭/Xiangtan）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(36,'sintering_location','DX','DX：碳化（东莞/Dongguan） + 石墨化（湘潭/Xiangtan）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(37,'sintering_location','WF','WF：外发',4,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(38,'material_type_for_firing','R','R：卷材（Roll）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(39,'material_type_for_firing','P','P：片材（Plate）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(40,'rolling_method','IF','IF：内部平压（In-house Flat）',1,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(41,'rolling_method','IR','IR：内部辊压（In-house Roll）',2,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(42,'rolling_method','OF','OF：外发平压（Outsource Flat）',3,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(43,'rolling_method','OR','OR：外发辊压（Outsource Roll）',4,1,1,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(44,'pi_film_thickness','25','25',1,1,0,NULL,'2025-09-20 14:18:01','2025-12-06 12:17:11'),(45,'pi_film_thickness','50','50',2,1,0,NULL,'2025-09-20 14:18:01','2025-12-06 12:17:11'),(46,'pi_film_thickness','55','55',3,1,0,NULL,'2025-09-20 14:18:01','2025-12-06 12:17:11'),(47,'pi_film_thickness','75','75',4,1,0,NULL,'2025-09-20 14:18:01','2025-12-06 12:17:11'),(48,'pi_film_thickness','100','100',5,1,0,NULL,'2025-09-20 14:18:01','2025-12-06 12:17:11'),(49,'pi_film_model','GH-38','GH-38',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(50,'pi_film_model','GP-43','GP-43',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(51,'pi_film_model','THK-43','THK-43',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(52,'pi_film_model','NA-38','NA-38',4,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(53,'pi_film_model','GH-50','GH-50',5,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(54,'pi_film_model','THK-55','THK-55',6,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(55,'pi_film_model','NA-50','NA-50',7,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(56,'pi_film_model','GP-55','GP-55',8,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(57,'pi_film_model','TH5-50','TH5-50',9,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(58,'pi_film_model','NA-62','NA-62',10,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(59,'pi_film_model','GH-62','GH-62',11,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(60,'pi_film_model','TH5-62','TH5-62',12,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(61,'pi_film_model','GH-68','GH-68',13,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(62,'pi_film_model','TH5-68','TH5-68',12,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(63,'pi_film_model','GH-75','GH-75',15,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(64,'pi_film_model','THK-65','THK-65',16,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(65,'pi_film_model','THK-72','THK-72',11,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(66,'pi_film_model','GH-90','GH-90',18,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(67,'pi_film_model','TH5-75','TH5-75',14,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(68,'pi_film_model','TH5-90','TH5-90',20,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(69,'pi_film_model','GH-100','GH-100',21,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(70,'pi_film_model','GH-125','GH-125',22,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(71,'pi_film_model','TH5-100','TH5-100',23,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(72,'pi_film_model','GH-140','GH-140',24,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(73,'pi_film_model','TH5-125','TH5-125',25,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(74,'pi_film_model','GH-150','GH-150',26,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(75,'pi_film_model','TH5-140','TH5-140',27,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(76,'pi_film_model','GTS-43','GTS-43',28,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(77,'pi_film_model','TH5-150','TH5-150',29,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(78,'pi_film_model','GTS-55','GTS-55',30,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(79,'pi_film_model','THK-150','THK-150',31,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(80,'pi_film_model','GTS-160','GTS-160',32,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(81,'pi_film_model','THK-160','THK-160',33,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(82,'pi_film_model','GTS-170','GTS-170',34,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(83,'pi_film_model','THS-150','THS-150',35,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(84,'pi_film_model','GP-65','GP-65',36,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(85,'pi_film_model','THS-160','THS-160',30,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(86,'pi_film_model','GP-72','GP-72',38,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(87,'pi_film_model','GP-90','GP-90',15,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(88,'pi_film_model','GP-100','GP-100',40,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(89,'pi_film_model','GP-105','GP-105',41,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(90,'pi_film_model','GP-150','GP-150',29,1,0,NULL,'2025-09-20 14:18:01','2025-12-09 07:43:09'),(91,'pi_manufacturer','时代','时代',1,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(92,'pi_manufacturer','达迈','达迈',2,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(93,'pi_manufacturer','欣邦','欣邦',3,1,0,NULL,'2025-09-20 14:18:01','2025-09-20 14:18:01'),(94,'pi_film_thickness','38','38',1,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(95,'pi_film_thickness','43','43',2,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(96,'pi_film_thickness','62','62',3,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(97,'pi_film_thickness','68','68',4,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(98,'pi_film_thickness','72','72',5,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(99,'pi_film_thickness','90','90',6,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(100,'pi_film_thickness','95','95',7,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(101,'pi_film_thickness','110','110',8,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(102,'pi_film_thickness','120','120',9,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(103,'pi_film_thickness','125','125',10,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(104,'pi_film_thickness','130','130',11,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(105,'pi_film_thickness','140','140',12,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(106,'pi_film_thickness','150','150',13,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(107,'pi_film_thickness','160','160',14,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(108,'pi_film_thickness','170','170',15,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(109,'pi_film_thickness','180','180',16,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(110,'pi_film_thickness','190','190',17,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(111,'pi_film_thickness','200','200',18,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(112,'pi_film_thickness','210','210',19,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(113,'pi_film_thickness','220','220',20,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(114,'pi_film_thickness','230','230',21,1,1,1,'2025-12-06 12:09:37','2025-12-06 12:09:37'),(115,'pi_film_model','HD-38','HD-38',1,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(116,'pi_film_model','TH5-38','TH5-38',2,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(117,'pi_film_model','GT-43','GT-43',3,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(118,'pi_film_model','THS-43','THS-43',4,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(119,'pi_film_model','HD-50','HD-50',5,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(120,'pi_film_model','LV-50','LV-50',6,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(121,'pi_film_model','GT-55','GT-55',7,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(122,'pi_film_model','THS-55','THS-55',8,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(123,'pi_film_model','HD-62','HD-62',9,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(124,'pi_film_model','LV-62','LV-62',10,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(125,'pi_film_model','LV-68','LV-68',13,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(126,'pi_film_model','THK-90','THK-90',16,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(127,'pi_film_model','GT-90','GT-90',17,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(128,'pi_film_model','THS-95','THS-95',33,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(129,'pi_film_model','GP-95','GP-95',19,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(130,'pi_film_model','THK-100','THK-100',20,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(131,'pi_film_model','GT-100','GT-100',21,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(132,'pi_film_model','THS-110','THS-110',22,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(133,'pi_film_model','GP-110','GP-110',23,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(134,'pi_film_model','THK-125','THK-125',24,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(135,'pi_film_model','GPA-125','GPA-125',25,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(136,'pi_film_model','THK-140','THK-140',26,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(137,'pi_film_model','GT-140','GT-140',27,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(138,'pi_film_model','TH5-160','TH5-160',28,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(139,'pi_film_model','THS-46','THS-46',31,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(140,'pi_film_model','GTS-65','GTS-65',32,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(141,'pi_film_model','GTS-90','GTS-90',34,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(142,'pi_film_model','THS-120','THS-120',35,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(143,'pi_film_model','THS-115','THS-115',36,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(144,'pi_film_model','GT-170','GT-170',37,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(145,'pi_film_model','GT-120','GT-120',38,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(146,'pi_film_model','GT-180','GT-180',39,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(147,'pi_film_model','GT-200','GT-200',40,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09'),(148,'pi_film_model','GT-220','GT-220',41,1,0,1,'2025-12-09 07:43:09','2025-12-09 07:43:09');
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
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='瀹為獙璁捐?鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_basic`
--

LOCK TABLES `experiment_basic` WRITE;
/*!40000 ALTER TABLE `experiment_basic` DISABLE KEYS */;
INSERT INTO `experiment_basic` VALUES (18,12,75.00,'N','RD','GH-38','2025-10-10','DG','R','IR',13,'啊书法大赛发发撒撒发生发','2025-10-10 05:02:16','2025-10-10 05:02:16'),(21,14,55.00,'D','TM','THK-55','2025-10-12','DG','R','IF',2,'asfasfasf','2025-10-12 03:21:50','2025-10-12 03:21:50'),(25,18,50.00,'D','BY','THK-43','2025-10-12','DG','R','IF',1,'啊发撒是否','2025-10-12 04:23:24','2025-10-12 04:23:24'),(29,19,25.00,'I','RD','GH-38','2025-10-16','DG','R','IF',2,'asfdasfa f艾弗森大师傅','2025-10-16 03:12:31','2025-10-16 03:12:31'),(35,25,25.00,'D','RD','GP-43','2025-10-20','DG','R','IF',1,'ASFDASFASFSA','2025-10-20 04:46:11','2025-10-20 04:46:11'),(36,26,55.00,'I','SA','THK-43','2025-10-31','DX','R','IF',1,'asfdasfasf','2025-10-31 06:00:01','2025-10-31 06:00:01'),(40,28,55.00,'N','RD','GH-150','2025-11-02','XT','R','IR',1,'内部烧制K2000样品，为客户送样建立库存','2025-11-01 18:54:01','2025-11-01 18:54:01'),(42,29,55.00,'N','RD','THK-55','2025-11-02','WF','R','IF',1,'内部研究THK55的PI膜可以达到的最大热扩散系数','2025-11-01 22:47:32','2025-11-01 22:47:32'),(64,36,25.00,'N','MP','GP-43','2025-11-30','XT','R','IF',1,'xxx','2025-11-30 04:54:24','2025-11-30 04:54:24'),(67,37,25.00,'I','RD','GP-43','2025-11-30','DG','R','IF',1,'xxx','2025-11-30 05:15:10','2025-11-30 05:15:10'),(76,39,25.00,'I','SA','GP-43','2025-12-01','DG','R','IF',1,'xxx','2025-12-01 04:52:56','2025-12-01 04:52:56'),(82,42,25.00,'I','RD','GH-38','2025-12-02','DG','R','IF',1,'asfdasfasf','2025-12-02 05:57:53','2025-12-02 05:57:53'),(92,45,25.00,'I','SA','GP-43','2025-12-05','XT','P','IF',1,'fasdfasfsafasfd asfd撒旦发射点','2025-12-05 03:55:17','2025-12-05 03:55:17'),(95,46,25.00,'I','SA','THK-55','2025-12-05','WF','P','IF',1,'dfasdasf','2025-12-05 04:29:04','2025-12-05 04:29:04'),(100,47,75.00,'I','SA','GH-38','2025-12-06','DG','R','OF',1,'asfdl垃圾啊放了多久 爱的方式了解啦发 了就安分的数量阿凡达了解了 艾弗森了FASFDAS FASFDASDFdsfasfasasffd阿斯蒂芬萨芬萨芬的撒旦飞洒飞洒飞洒发生范德萨撒范德萨发生放大沙发沙发风飒飒法大法师','2025-12-06 01:12:14','2025-12-06 01:12:14'),(110,50,150.00,'N','MP','GP-150','2025-12-10','DG','R','IR',1,'时代厚膜表面凸点情况改善','2025-12-09 16:47:12','2025-12-09 16:47:12'),(117,51,150.00,'N','RD','THK-150','2025-12-04','DG','R','IR',1,'优化达迈THK厚膜烧制U型问题','2025-12-09 17:05:49','2025-12-09 17:05:49'),(120,49,68.00,'N','RD','LV-68','2025-12-10','DG','R','IR',1,'大宽幅石墨良率改善','2025-12-09 17:19:01','2025-12-09 17:19:01'),(122,52,100.00,'N','RD','GH-100','2025-12-01','DG','R','IR',1,'新PI验证','2025-12-09 17:43:54','2025-12-09 17:43:54'),(124,53,55.00,'D','RD','THS-55','2025-12-10','DG','R','IR',2,'新PI验证','2025-12-09 20:58:47','2025-12-09 20:58:47'),(125,54,55.00,'D','RD','THS-55','2025-12-10','DG','R','IR',3,'新PI验证','2025-12-09 21:11:15','2025-12-09 21:11:15'),(126,55,90.00,'D','RD','GP-90','2025-11-19','XT','R','IR',5,'客户需求大宽幅（＞200mm）石墨，SGF040导热系数＞1500','2025-12-09 21:19:20','2025-12-09 21:19:20'),(128,56,25.00,'I','RD','GH-38','2025-12-11','DG','R','IF',1,'验证新材料','2025-12-11 04:20:39','2025-12-11 04:20:39'),(132,57,25.00,'I','RD','TH5-38','2025-12-11','DX','R','IF',1,'xcvxsdf','2025-12-11 04:32:01','2025-12-11 04:32:01');
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
  `carbon_film_thickness` decimal(8,2) DEFAULT NULL COMMENT '纰冲寲鑶滃帤搴?渭m) - 闈炲繀濉',
  `carbon_after_weight` decimal(10,3) DEFAULT NULL COMMENT '纰冲寲鍚庨噸閲忥紙kg锛? 闈炲繀濉',
  `carbon_yield_rate` decimal(5,2) DEFAULT NULL COMMENT '纰冲寲鎴愮⒊鐜? - 闈炲繀濉',
  `carbon_loading_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲瑁呰浇鏂瑰紡鐓х墖璺?緞',
  `carbon_sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲鏍峰搧鐓х墖璺?緞',
  `carbon_other_params` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纰冲寲鍏跺畠鍙傛暟鏂囦欢璺?緞',
  `carbon_notes` text COLLATE utf8mb4_unicode_ci COMMENT '纰冲寲琛ュ厖璇存槑',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_carbon_furnace` (`carbon_furnace_number`),
  KEY `idx_carbon_max_temp` (`carbon_max_temp`),
  KEY `idx_temp_performance` (`carbon_max_temp`,`carbon_yield_rate`),
  CONSTRAINT `experiment_carbon_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='纰冲寲鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_carbon`
--

LOCK TABLES `experiment_carbon` WRITE;
/*!40000 ALTER TABLE `experiment_carbon` DISABLE KEYS */;
INSERT INTO `experiment_carbon` VALUES (4,12,'C01',4,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1222.00,122,1.00,3.000,22.00,NULL,NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(6,14,'C01',2,'','',NULL,NULL,'2025-10-08 00:00:00','2025-10-17 00:00:00',NULL,NULL,NULL,NULL,1111.00,132,2.00,2.000,2.00,NULL,NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(10,18,'asf',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,111.00,11,11.00,2.000,2.00,NULL,NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(13,19,'撒地方',1,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,1111,11.00,11.000,98.00,NULL,NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(14,26,'C01',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,1,1.00,2.000,2.00,NULL,NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(16,28,'C01',18,'YZ9','碳纸',10.0000,112.00,'2025-11-06 00:00:00','2025-11-08 00:00:00',NULL,NULL,NULL,NULL,1100.00,800,78.00,180.000,98.00,NULL,NULL,NULL,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(17,29,'C02',14,'T11','碳纸',33.0000,122.00,'2025-11-03 00:00:00','2025-11-04 00:00:00',500,55.00,700,60.00,1200.00,1000,66.00,200.000,96.00,NULL,NULL,NULL,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(21,37,'dds',2,'safd','asfdas',2.0000,2.00,'2025-11-30 21:14:57','2025-12-25 00:00:00',1111,1.00,1111,1111.00,2222.00,1,1.00,1.000,1.00,NULL,NULL,NULL,'','2025-11-30 05:15:10','2025-11-30 05:15:10'),(24,39,'ddZ',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1111.00,3,2.00,2.000,2.00,NULL,NULL,NULL,'','2025-12-01 04:52:56','2025-12-01 04:52:56'),(28,42,'asfasfdasfda',2,'asfdasfdsa','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-02 05:57:53','2025-12-02 05:57:53'),(35,45,'saf',2,'sadf','asfsd',1.0000,1.00,NULL,NULL,NULL,NULL,NULL,NULL,1111.00,3,2.00,2.000,1.00,NULL,NULL,NULL,'','2025-12-05 03:55:17','2025-12-05 03:55:17'),(36,46,'asdfas',2,'asfasfd','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-05 04:29:04','2025-12-05 04:29:04'),(40,47,'SS',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,2,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-06 01:12:14','2025-12-06 01:12:14'),(43,50,'C17',123,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1680,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 16:47:12','2025-12-09 16:47:12'),(47,51,'C06',12,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1650,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 17:05:49','2025-12-09 17:05:49'),(50,49,'C02',23,'A71','碳纸',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1320,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 17:19:01','2025-12-09 17:19:01'),(51,52,'C17',34,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1360,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 17:43:54','2025-12-09 17:43:54'),(52,54,'C01',3,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1360,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 21:11:15','2025-12-09 21:11:15'),(53,55,'C02',21,'','套筒',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1200.00,1350,NULL,26.000,NULL,NULL,NULL,NULL,'','2025-12-09 21:19:20','2025-12-09 21:19:20'),(54,56,'TTZ',2,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-11 04:20:39','2025-12-11 04:20:39'),(57,57,'fdsa',1,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','2025-12-11 04:32:01','2025-12-11 04:32:01');
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
  `gas_pressure` decimal(10,4) DEFAULT NULL COMMENT '姘斿帇鍊?- 闈炲繀濉',
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
  `graphite_yield_rate` decimal(5,2) DEFAULT NULL COMMENT '鐭冲ⅷ鍖栨垚纰崇巼% - 闈炲繀濉',
  `graphite_loading_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栬?杞芥柟寮忕収鐗囪矾寰',
  `graphite_sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栨牱鍝佺収鐗囪矾寰',
  `graphite_min_thickness` decimal(8,2) DEFAULT NULL COMMENT '鐭冲ⅷ鍘嬪欢鏈?杽鏋侀檺锛堢煶澧ㄧ悊璁哄瘑搴?.26g/cm鲁锛',
  `graphite_other_params` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鐭冲ⅷ鍖栧叾瀹冨弬鏁版枃浠惰矾寰',
  `graphite_notes` text COLLATE utf8mb4_unicode_ci COMMENT '鐭冲ⅷ鍖栬ˉ鍏呰?鏄',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_graphite_furnace` (`graphite_furnace_number`),
  KEY `idx_graphite_max_temp` (`graphite_max_temp`),
  KEY `idx_graphite_performance` (`graphite_max_temp`,`graphite_yield_rate`),
  CONSTRAINT `experiment_graphite_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鐭冲ⅷ鍖栧弬鏁拌〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_graphite`
--

LOCK TABLES `experiment_graphite` WRITE;
/*!40000 ALTER TABLE `experiment_graphite` DISABLE KEYS */;
INSERT INTO `experiment_graphite` VALUES (4,12,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1222.00,23.00,2.00,122,2.000,33.00,NULL,NULL,NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(6,14,'G01',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,2.00,1.00,1.00,123,2.000,88.00,NULL,NULL,NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(8,18,'asfd',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1111.00,1.00,3.00,0,2.000,1.00,NULL,NULL,NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(11,19,'3呃4',NULL,NULL,NULL,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,111.00,111.00,22.00,2,1.000,2.00,NULL,NULL,NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(12,26,'SAF',NULL,NULL,NULL,2.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,1222.00,111.00,22.00,2,1.000,22.00,NULL,NULL,NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(13,28,'G02',100,'2025-11-09 00:00:00','2025-11-12 00:00:00',22.0000,1000.00,1500.00,55.00,1700.00,50.00,1900.00,48.00,2100.00,45.00,2400.00,43.00,2800.00,40.00,40.00,2850.00,480.00,90.00,1500,170.000,99.00,NULL,NULL,11.00,NULL,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(14,29,'G04',33,'2025-11-05 00:00:00','2025-11-10 00:00:00',3.0000,100.00,1500.00,55.00,1800.00,50.00,2000.00,50.00,2100.00,45.00,2400.00,40.00,2800.00,35.00,50.00,2850.00,200.00,85.00,5000,180.000,99.00,NULL,NULL,32.00,NULL,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(16,39,'22',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,3.00,NULL,NULL,NULL,2.000,NULL,NULL,NULL,NULL,NULL,'','2025-12-01 04:52:56','2025-12-01 04:52:56'),(21,45,'fasdasfd',2,'2025-12-05 19:46:50','2025-12-18 00:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2.00,2222.00,3.00,2.00,1111,3.000,3.00,NULL,NULL,2.00,NULL,'','2025-12-05 03:55:17','2025-12-05 03:55:17'),(25,47,'AFSDAFS',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1.00,1.00,2.00,2.00,2,2.000,NULL,NULL,NULL,NULL,NULL,'','2025-12-06 01:12:14','2025-12-06 01:12:14'),(28,50,'G011',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,129.00,2750.00,147.00,0.86,3890,20.000,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 16:47:12','2025-12-09 16:47:12'),(31,51,'G031',74,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,204.00,2900.00,116.00,0.87,3980,16.500,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 17:05:49','2025-12-09 17:05:49'),(33,49,'G131',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,83.00,2800.00,210.00,0.88,1460,42.360,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 17:19:01','2025-12-09 17:19:01'),(34,52,'G022',124,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,101.00,2810.00,119.00,0.85,2140,2.700,NULL,NULL,NULL,48.00,NULL,'','2025-12-09 17:43:54','2025-12-09 17:43:54'),(35,54,'G061',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,75.00,2900.00,100.00,0.88,1430,12.100,NULL,NULL,NULL,52.00,NULL,'','2025-12-09 21:11:15','2025-12-09 21:11:15'),(36,55,'G062',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,124.00,2850.00,210.00,0.87,2100,23.800,NULL,NULL,NULL,NULL,NULL,'','2025-12-09 21:19:20','2025-12-09 21:19:20');
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
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鏉惧嵎鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_loose`
--

LOCK TABLES `experiment_loose` WRITE;
/*!40000 ALTER TABLE `experiment_loose` DISABLE KEYS */;
INSERT INTO `experiment_loose` VALUES (2,12,'',NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(3,14,'',NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(4,18,'',NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(5,19,'',NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(6,26,'',NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(8,28,'内芯',22.00,35.00,50.00,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(9,29,'Y形',3.00,11.00,33.00,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(14,36,'',2.00,NULL,2.00,'2025-11-30 04:54:24','2025-11-30 04:54:24'),(18,39,'sdf',NULL,NULL,NULL,'2025-12-01 04:52:56','2025-12-01 04:52:56'),(22,45,'asfd',2.00,2.00,NULL,'2025-12-05 03:55:17','2025-12-05 03:55:17'),(24,47,'AFSD',NULL,NULL,NULL,'2025-12-06 01:12:14','2025-12-06 01:12:14'),(27,50,'小管芯',370.00,350.00,370.00,'2025-12-09 16:47:12','2025-12-09 16:47:12'),(32,51,'小管芯',340.00,345.00,350.00,'2025-12-09 17:05:49','2025-12-09 17:05:49'),(35,49,'小管芯',152.00,162.00,150.00,'2025-12-09 17:19:01','2025-12-09 17:19:01'),(36,52,'小管芯',200.00,210.00,205.00,'2025-12-09 17:43:54','2025-12-09 17:43:54'),(37,54,'小管芯',120.00,125.00,120.00,'2025-12-09 21:11:15','2025-12-09 21:11:15'),(38,55,'小管芯',210.00,215.00,220.00,'2025-12-09 21:19:20','2025-12-09 21:19:20');
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
  `firing_rolls` int DEFAULT NULL COMMENT '鐑у埗鍗锋暟',
  `pi_notes` text COLLATE utf8mb4_unicode_ci COMMENT 'PI鑶滆ˉ鍏呰?鏄',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  KEY `idx_pi_manufacturer` (`pi_manufacturer`),
  KEY `idx_batch_number` (`batch_number`),
  CONSTRAINT `experiment_pi_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PI鑶滃弬鏁拌〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_pi`
--

LOCK TABLES `experiment_pi` WRITE;
/*!40000 ALTER TABLE `experiment_pi` DISABLE KEYS */;
INSERT INTO `experiment_pi` VALUES (5,12,'时代',25.00,'GP-43',NULL,'',2.000,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(7,14,'时代',25.00,'GH-38',NULL,'',2.000,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(9,18,'时代',25.00,'GH-38',NULL,'',1.000,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(12,19,'时代',25.00,'GH-38',NULL,'',2.000,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(14,26,'达迈',55.00,'THK-43',NULL,'',2.000,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(17,28,'时代',55.00,'THK-55',500.00,'afjalj2345435r',100.000,NULL,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(18,29,'达迈',55.00,'THK-55',555.00,'asf3343',222.000,NULL,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(31,39,'时代',25.00,'GH-38',1.00,'',2.000,NULL,'','2025-12-01 04:52:56','2025-12-01 04:52:56'),(35,45,'时代',25.00,'GP-43',NULL,'',2.000,NULL,'','2025-12-05 03:55:17','2025-12-05 03:55:17'),(39,47,'时代',25.00,'GH-38',NULL,'',2.000,NULL,'','2025-12-06 01:12:14','2025-12-06 01:12:14'),(46,50,'时代',140.00,'GP-150',171.00,'',39.380,NULL,'PI膜型号为GP140，无该选项','2025-12-09 16:47:12','2025-12-09 16:47:12'),(52,51,'达迈',150.00,'THK-150',134.00,'',33.000,21,'','2025-12-09 17:05:49','2025-12-09 17:05:49'),(55,49,'SKC',68.00,'LV-68',246.00,'J2259210631210',81.470,NULL,'','2025-12-09 17:19:01','2025-12-09 17:19:01'),(56,52,'时代',100.00,'GH-100',141.00,'702320CDS1-1B',5.400,2,'样品料','2025-12-09 17:43:54','2025-12-09 17:43:54'),(57,54,'达迈',55.00,'THS-55',NULL,'',23.000,NULL,'','2025-12-09 21:11:15','2025-12-09 21:11:15'),(58,55,'时代',90.00,'GP-90',256.00,'J22435T0S4-5B',46.000,21,'','2025-12-09 21:19:20','2025-12-09 21:19:20');
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
  `cohesion` decimal(8,2) DEFAULT NULL COMMENT '鍐呰仛鍔涳紙gf锛? 闈炲繀濉',
  `peel_strength` decimal(8,2) DEFAULT NULL COMMENT '鍓ョ?鍔涳紙gf锛? 闈炲繀濉',
  `roughness` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '绮楃硻搴?- 闈炲繀濉',
  `appearance_desc` text COLLATE utf8mb4_unicode_ci COMMENT '澶栬?鍙婁笉鑹?儏鍐垫弿杩',
  `appearance_defect_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '澶栬?涓嶈壇鐓х墖璺?緞',
  `sample_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鏍峰搧鐓х墖璺?緞',
  `experiment_summary` text COLLATE utf8mb4_unicode_ci COMMENT '瀹為獙鎬荤粨',
  `other_files` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鍏跺畠鏂囦欢璺?緞',
  `remarks` text COLLATE utf8mb4_unicode_ci COMMENT '澶囨敞',
  `bond_strength` decimal(8,2) DEFAULT NULL COMMENT '缁撳悎鍔涳紙鏁板?鍗曚綅寰呯‘璁わ級',
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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鎴愬搧鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_product`
--

LOCK TABLES `experiment_product` WRITE;
/*!40000 ALTER TABLE `experiment_product` DISABLE KEYS */;
INSERT INTO `experiment_product` VALUES (3,12,'',2.00,'100 X20',2.000,2.000000,2.000,2.0000,2.00,2.00,'SF','ASFDASFAS',NULL,NULL,'ASFASF 第三方',NULL,'SAFDASF',NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(5,14,'',2.00,'100',1.000,2.000000,2.000,2.0000,2.00,1.00,'asfd','啊书法大赛发',NULL,NULL,'afasf asfafs',NULL,'safasf',NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(7,18,'',2.00,'111',2.000,2.000000,1.000,1.0000,1.00,1.00,'sfd','asdfasfd',NULL,NULL,'asdfasfasfdas',NULL,'afsdasf',NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(9,19,'',2.00,'11',2.000,11.000000,2.000,111.0000,2.00,1.00,'阿斯弗','啊沙发上',NULL,NULL,'艾弗森dasf',NULL,'afsas',NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(10,26,'',2.00,'AAA',1.000,1.000000,1.000,1.0000,1.00,1.00,'ASFD','ASFASFASASF',NULL,NULL,'AFSDASFASFASFSA',NULL,'',NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(11,28,'8798234',38.00,'480 x 30',2.213,1055.000000,1680.000,0.8500,60.00,15.00,'光滑','外观良好，部分闪电纹和凸点',NULL,NULL,'本次实验达成了实验目的，导热系数可以满足客户要求，计划下一步提供石墨化温度，继续提升K值',NULL,'无',NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(12,29,'YASIFJ2323423',38.00,'100 X30',2.334,1068.000000,1700.000,8.5000,60.00,3.00,'正常','外观不良，大量闪电纹',NULL,NULL,'外观不良严重，需要和供应商确认重新取得材料烧制',NULL,'',NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(16,45,'fsasf',1.00,'111',2.000,2.000000,1.000,2.0000,2.00,2.00,'asf','啊沙发沙发阿斯弗萨芬阿瑟啊沙发沙发撒发生',NULL,NULL,' 啊风飒飒法啊沙发上法算法法法艾弗森发a',NULL,'啊首发式发生发生法sf',1.00,'2025-12-05 03:55:17','2025-12-05 03:55:17'),(20,47,'ASFDASF',2.00,'111',1.000,2.000000,1.000,2.0000,1.00,1.00,'SS','',NULL,NULL,'ASFASFAASA啊师傅打法沙发沙发沙发沙发但是从，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是从，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是从，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是从，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是从，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，ASFASFAASA啊师傅打法沙发沙发沙发沙发但是，',NULL,'SAFDAS',NULL,'2025-12-06 01:12:14','2025-12-06 01:12:14'),(21,50,'',67.00,'140mm*78m',1.937,853.041000,1404.463,0.8500,127.66,NULL,'','整卷＜0.3mm凸点分布',NULL,NULL,'大凸点情况减少至10m/个，但小凸点并未改善，整卷密集分布',NULL,'',12.80,'2025-12-09 16:47:12','2025-12-09 16:47:12'),(22,51,'',73.00,'110mm*82m',2.194,878.698000,1638.629,0.8500,51.17,16.63,'','一层U型，前两米部分分层',NULL,NULL,'发泡厚度大，辊压压不下去，裸压仅能压到72-75，U型问题有所改善',NULL,'',NULL,'2025-12-09 17:05:49','2025-12-09 17:05:49'),(24,49,'',39.00,'200mm*155m',2.193,855.320000,1486.860,0.8500,NULL,NULL,'','存在闪电纹',NULL,NULL,'良率有所提升，由原来的93%提升为95%',NULL,'',NULL,'2025-12-09 17:19:01','2025-12-09 17:19:01'),(25,52,'',49.00,'115mm*108m',2.066,797.405000,1400.225,0.8500,168.90,NULL,'','整卷凸点多且密集，一卷两个粘连',NULL,NULL,'1. 石墨膜表面凸点多，PI材料NG\n2. 2810℃材料热扩散＜850，需提高温度验证性能可行性',NULL,'',NULL,'2025-12-09 17:43:54','2025-12-09 17:43:54'),(26,54,'1层',54.00,'82mm*120m',2.192,992.230000,1848.700,0.8500,NULL,NULL,'','外观较粗糙',NULL,NULL,'性能满足要求，外观合格',NULL,'',NULL,'2025-12-09 21:11:15','2025-12-09 21:11:15'),(27,55,'3层',38.00,'200mm*125m',2.205,879.340000,1648.100,0.8500,NULL,NULL,'','部分U型',NULL,NULL,'性能达标，外观满足出货要求',NULL,'',NULL,'2025-12-09 21:19:20','2025-12-09 21:19:20');
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
  `rolling_notes` text COLLATE utf8mb4_unicode_ci COMMENT '鍘嬪欢琛ュ厖璇存槑',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_experiment_id` (`experiment_id`),
  CONSTRAINT `experiment_rolling_ibfk_1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鍘嬪欢鍙傛暟琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiment_rolling`
--

LOCK TABLES `experiment_rolling` WRITE;
/*!40000 ALTER TABLE `experiment_rolling` DISABLE KEYS */;
INSERT INTO `experiment_rolling` VALUES (2,12,'',NULL,NULL,NULL,NULL,'2025-10-10 05:02:16','2025-10-10 05:02:16'),(3,14,'',NULL,NULL,NULL,NULL,'2025-10-12 03:21:50','2025-10-12 03:21:50'),(4,18,'',NULL,NULL,NULL,NULL,'2025-10-12 04:23:24','2025-10-12 04:23:24'),(5,19,'',NULL,NULL,NULL,NULL,'2025-10-16 03:12:31','2025-10-16 03:12:31'),(6,26,'',NULL,NULL,NULL,NULL,'2025-10-31 06:00:01','2025-10-31 06:00:01'),(7,28,'Y02',2.00,5.00,100.000,NULL,'2025-11-01 18:54:01','2025-11-01 18:54:01'),(8,29,'Y01',2.00,12.00,100.000,NULL,'2025-11-01 22:47:32','2025-11-01 22:47:32'),(12,45,'22sfd',2.00,NULL,1.000,'asfdasf撒子范德萨','2025-12-05 03:55:17','2025-12-05 03:55:17'),(14,50,'Y09',3.20,NULL,NULL,'','2025-12-09 16:47:12','2025-12-09 16:47:12'),(16,51,'Y10',2.70,NULL,NULL,'','2025-12-09 17:05:49','2025-12-09 17:05:49'),(17,49,'',NULL,NULL,NULL,'','2025-12-09 17:19:01','2025-12-09 17:19:01'),(18,52,'Y02',3.90,NULL,NULL,'','2025-12-09 17:43:54','2025-12-09 17:43:54'),(19,54,'',NULL,NULL,NULL,'','2025-12-09 21:11:15','2025-12-09 21:11:15'),(20,55,'Y12',3.98,NULL,NULL,'','2025-12-09 21:19:20','2025-12-09 21:19:20');
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
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='瀹為獙涓昏〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiments`
--

LOCK TABLES `experiments` WRITE;
/*!40000 ALTER TABLE `experiments` DISABLE KEYS */;
INSERT INTO `experiments` VALUES (12,'75NRD-GH38-251010DG-RIR13','submitted',1,'2025-10-10 05:02:16','2025-10-10 05:02:16','2025-10-10 05:02:16',1,''),(14,'55DTM-THK55-251012DG-RIF02','submitted',1,'2025-10-12 03:21:50','2025-10-12 03:21:50','2025-10-12 03:21:50',1,''),(18,'50DBY-THK43-251012DG-RIF01','submitted',1,'2025-10-12 04:23:24','2025-10-12 04:23:24','2025-10-12 04:23:24',1,''),(19,'25IRD-GH38-251016DG-RIF02','submitted',1,'2025-10-16 03:10:53','2025-10-16 03:12:31','2025-10-16 11:12:31',1,''),(25,'25DRD-GP43-251020DG-RIF01','draft',1,'2025-10-20 04:46:11','2025-10-20 04:46:11',NULL,1,''),(26,'55ISA-THK43-251031DX-RIF01','submitted',1,'2025-10-31 06:00:01','2025-10-31 06:00:01','2025-10-31 14:00:01',1,NULL),(28,'55NRD-GH150-251102XT-RIR01','submitted',1,'2025-11-01 18:41:11','2025-11-01 18:54:01','2025-11-02 02:54:01',1,''),(29,'55NRD-THK55-251102WF-RIF01','submitted',1,'2025-11-01 22:41:35','2025-11-01 22:47:32','2025-11-02 06:47:32',1,''),(36,'25NMP-GP43-251130XT-RIF01','draft',1,'2025-11-30 04:38:59','2025-11-30 04:54:24',NULL,1,''),(37,'25IRD-GP43-251130DG-RIF01','draft',1,'2025-11-30 05:12:14','2025-11-30 05:15:10',NULL,1,''),(39,'25ISA-GP43-251201DG-RIF01','draft',1,'2025-12-01 04:47:54','2025-12-01 04:52:56',NULL,1,''),(42,'25IRD-GH38-251202DG-RIF01','draft',1,'2025-12-02 05:57:53','2025-12-02 05:57:53',NULL,1,''),(45,'25ISA-GP43-251205XT-PIF01','submitted',1,'2025-12-05 03:46:19','2025-12-05 03:55:17','2025-12-05 11:55:17',1,''),(46,'25ISA-THK55-251205WF-PIF01','draft',1,'2025-12-05 04:27:12','2025-12-05 04:29:04',NULL,1,''),(47,'75ISA-GH38-251206DG-ROF01','draft',1,'2025-12-06 00:55:27','2025-12-06 01:12:14',NULL,1,''),(49,'68NRD-LV68-251210DG-RIR01','submitted',4,'2025-12-09 16:26:11','2025-12-09 17:19:01','2025-12-10 01:19:01',1,''),(50,'150NMP-GP150-251210DG-RIR01','submitted',4,'2025-12-09 16:35:35','2025-12-09 16:47:12','2025-12-10 00:47:12',1,''),(51,'150NRD-THK150-251204DG-RIR01','submitted',4,'2025-12-09 16:51:15','2025-12-09 17:05:48','2025-12-10 01:05:48',1,''),(52,'100NRD-GH100-251201DG-RIR01','submitted',4,'2025-12-09 17:20:52','2025-12-09 17:43:54','2025-12-10 01:43:54',1,''),(53,'55DRD-THS55-251210DG-RIR02','draft',4,'2025-12-09 17:48:41','2025-12-09 20:58:47',NULL,1,''),(54,'55DRD-THS55-251210DG-RIR03','submitted',4,'2025-12-09 21:11:15','2025-12-09 21:11:15','2025-12-10 05:11:15',1,NULL),(55,'90DRD-GP90-251119XT-RIR05','submitted',4,'2025-12-09 21:19:20','2025-12-09 21:19:20','2025-12-10 05:19:20',1,NULL),(56,'25IRD-GH38-251211DG-RIF01','draft',1,'2025-12-11 04:20:24','2025-12-11 04:20:39',NULL,1,''),(57,'25IRD-TH538-251211DX-RIF01','draft',4,'2025-12-11 04:21:52','2025-12-11 04:32:01',NULL,1,'');
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
  `experiment_id` int DEFAULT NULL COMMENT '实验ID（上传时可为空，提交时更新）',
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
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鏂囦欢涓婁紶璁板綍琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_uploads`
--

LOCK TABLES `file_uploads` WRITE;
/*!40000 ALTER TABLE `file_uploads` DISABLE KEYS */;
INSERT INTO `file_uploads` VALUES (1,39,'carbon_loading_photo','qq.JPG','carbon_loading_photo_53dd47c195304977a4f5a7dad741eb5c.jpg','2025/11/temp/carbon_loading_photo_53dd47c195304977a4f5a7dad741eb5c.jpg',76857,'jpg','image/jpeg',1,'2025-11-30 00:55:55'),(2,39,'carbon_sample_photo','DJI_0506.JPG','carbon_sample_photo_1abc8d31702042c4a53c19bc61168548.jpg','2025/11/temp/carbon_sample_photo_1abc8d31702042c4a53c19bc61168548.jpg',1780250,'jpg','image/jpeg',1,'2025-11-30 00:56:17'),(3,39,'graphite_loading_photo','DJI_0490.JPG','graphite_loading_photo_c875634afc8b44b7b35c172b5e94198a.jpg','2025/11/temp/graphite_loading_photo_c875634afc8b44b7b35c172b5e94198a.jpg',1318654,'jpg','image/jpeg',1,'2025-11-30 00:56:51'),(4,39,'graphite_sample_photo','DJI_0490.JPG','graphite_sample_photo_77321225c5fb483da998b343cea4447f.jpg','2025/11/temp/graphite_sample_photo_77321225c5fb483da998b343cea4447f.jpg',1318654,'jpg','image/jpeg',1,'2025-11-30 00:56:59'),(5,39,'graphite_other_params','EP2636643A1.pdf','graphite_other_params_654148df1fed4af1b7ef71b30807b3c6.pdf','2025/11/temp/graphite_other_params_654148df1fed4af1b7ef71b30807b3c6.pdf',314565,'pdf','application/pdf',1,'2025-11-30 00:57:09'),(6,39,'appearance_defect_photo','20250812211528.png','appearance_defect_photo_b9db3de3160c4902bd6b561e1ad96277.png','2025/11/temp/appearance_defect_photo_b9db3de3160c4902bd6b561e1ad96277.png',185769,'png','image/png',1,'2025-11-30 00:57:36'),(7,39,'appearance_defect_photo','DJI_0492.JPG','appearance_defect_photo_7916898b989f4266be3c197ec15ade4e.jpg','2025/11/temp/appearance_defect_photo_7916898b989f4266be3c197ec15ade4e.jpg',1347221,'jpg','image/jpeg',1,'2025-11-30 00:57:57'),(8,39,'sample_photo','DJI_0499.JPG','sample_photo_df72059d11e047a98c786f04963aaaea.jpg','2025/11/temp/sample_photo_df72059d11e047a98c786f04963aaaea.jpg',1379034,'jpg','image/jpeg',1,'2025-11-30 00:58:04'),(9,39,'other_files','US5091025.pdf','other_files_bd4232e2331448f5b32031d14d830903.pdf','2025/11/temp/other_files_bd4232e2331448f5b32031d14d830903.pdf',755860,'pdf','application/pdf',1,'2025-11-30 00:58:29'),(10,39,'carbon_loading_photo','DJI_0486.JPG','carbon_loading_photo_f3598093894a4de28a93a51d1bf8911c.jpg','2025/11/temp/carbon_loading_photo_f3598093894a4de28a93a51d1bf8911c.jpg',1295015,'jpg','image/jpeg',1,'2025-11-30 01:13:16'),(11,39,'carbon_sample_photo','DJI_0499.JPG','carbon_sample_photo_6fb0f851f30f46ca834b2890ea717b04.jpg','2025/11/temp/carbon_sample_photo_6fb0f851f30f46ca834b2890ea717b04.jpg',1379034,'jpg','image/jpeg',1,'2025-11-30 01:13:22'),(12,39,'carbon_other_params','US5091025.pdf','carbon_other_params_9c62ea5fdde04ec7a5d6cdff525fdeec.pdf','2025/11/temp/carbon_other_params_9c62ea5fdde04ec7a5d6cdff525fdeec.pdf',755860,'pdf','application/pdf',1,'2025-11-30 02:54:07'),(13,39,'carbon_loading_photo','DJI_0508.JPG','carbon_loading_photo_ebe49782f60148bf89ea61c5a64d83db.jpg','2025/11/temp/carbon_loading_photo_ebe49782f60148bf89ea61c5a64d83db.jpg',1540936,'jpg','image/jpeg',1,'2025-11-30 03:27:32'),(14,39,'carbon_sample_photo','DJI_0508.JPG','carbon_sample_photo_f0ba914f0f564bcfa97f6e70b63cd808.jpg','2025/11/temp/carbon_sample_photo_f0ba914f0f564bcfa97f6e70b63cd808.jpg',1540936,'jpg','image/jpeg',1,'2025-11-30 03:27:45'),(15,39,'carbon_other_params','肖博宇简历.docx','carbon_other_params_1e3e99d1f70e40acaf9efd0d7beb7c45.docx','2025/11/temp/carbon_other_params_1e3e99d1f70e40acaf9efd0d7beb7c45.docx',2316757,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-11-30 03:27:53'),(16,39,'carbon_loading_photo','DJI_0489.JPG','carbon_loading_photo_aea0e2dfebea49bb9364e7dc55ab3930.jpg','2025/11/temp/carbon_loading_photo_aea0e2dfebea49bb9364e7dc55ab3930.jpg',1598619,'jpg','image/jpeg',1,'2025-11-30 04:10:21'),(17,39,'carbon_sample_photo','DJI_0509.JPG','carbon_sample_photo_56edd8b42fa64168b6d2a4d468305b55.jpg','2025/11/temp/carbon_sample_photo_56edd8b42fa64168b6d2a4d468305b55.jpg',1508737,'jpg','image/jpeg',1,'2025-11-30 04:10:30'),(18,39,'carbon_other_params','肖博宇简历.docx','carbon_other_params_f2aa5f4be43f4bd892f7eebe7804c9f2.docx','2025/11/temp/carbon_other_params_f2aa5f4be43f4bd892f7eebe7804c9f2.docx',2316757,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-11-30 04:10:43'),(19,39,'carbon_other_params','分卷.xlsx','carbon_other_params_744db33e806a43f09d41b6720c2e4ab5.xlsx','2025/11/temp/carbon_other_params_744db33e806a43f09d41b6720c2e4ab5.xlsx',8976,'xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',1,'2025-11-30 04:13:14'),(20,39,'carbon_other_params','EP2636643A1.pdf','carbon_other_params_69d5b56827d444da920dcc22e67c515c.pdf','2025/11/temp/carbon_other_params_69d5b56827d444da920dcc22e67c515c.pdf',314565,'pdf','application/pdf',1,'2025-11-30 04:15:04'),(21,39,'carbon_sample_photo','DJI_0489.JPG','carbon_sample_photo_a9c83d444c144a56ac17f2dd89b83d2a.jpg','2025/11/temp/carbon_sample_photo_a9c83d444c144a56ac17f2dd89b83d2a.jpg',1598619,'jpg','image/jpeg',1,'2025-11-30 04:15:12'),(22,39,'carbon_loading_photo','DJI_0508.JPG','carbon_loading_photo_c2ab8aa4c55c48de8aa0874141c7f4ad.jpg','2025/11/temp/carbon_loading_photo_c2ab8aa4c55c48de8aa0874141c7f4ad.jpg',1540936,'jpg','image/jpeg',1,'2025-11-30 04:39:06'),(23,39,'carbon_sample_photo','DJI_0486.JPG','carbon_sample_photo_820697b0c54f46ba8e18136c3d5ee71d.jpg','2025/11/temp/carbon_sample_photo_820697b0c54f46ba8e18136c3d5ee71d.jpg',1295015,'jpg','image/jpeg',1,'2025-11-30 04:39:15'),(24,39,'carbon_other_params','肖博宇简历.docx','carbon_other_params_dca8e330a8974e4997285312420758da.docx','2025/11/temp/carbon_other_params_dca8e330a8974e4997285312420758da.docx',2316757,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-11-30 04:39:21'),(25,39,'graphite_loading_photo','DJI_0492.JPG','graphite_loading_photo_3dc663ed27334d2ca054d765de5ffd8b.jpg','2025/11/temp/graphite_loading_photo_3dc663ed27334d2ca054d765de5ffd8b.jpg',1347221,'jpg','image/jpeg',1,'2025-11-30 04:39:53'),(26,39,'graphite_sample_photo','DJI_0491.JPG','graphite_sample_photo_55629e98d7ea4d3b81da8129af496137.jpg','2025/11/temp/graphite_sample_photo_55629e98d7ea4d3b81da8129af496137.jpg',1181156,'jpg','image/jpeg',1,'2025-11-30 04:39:58'),(27,39,'graphite_other_params','US5091025.pdf','graphite_other_params_732bffff713a4e928c0d2d1505a2b62b.pdf','2025/11/temp/graphite_other_params_732bffff713a4e928c0d2d1505a2b62b.pdf',755860,'pdf','application/pdf',1,'2025-11-30 04:40:07'),(28,39,'appearance_defect_photo','微信图片_20250812211528.png','appearance_defect_photo_84af333cc4764417aa2810af96017d89.png','2025/11/temp/appearance_defect_photo_84af333cc4764417aa2810af96017d89.png',185769,'png','image/png',1,'2025-11-30 04:40:35'),(29,39,'sample_photo','微信图片_20250812133520.jpg','sample_photo_9242621f70334524bbb30be9ad0d171e.jpg','2025/11/temp/sample_photo_9242621f70334524bbb30be9ad0d171e.jpg',239957,'jpg','image/jpeg',1,'2025-11-30 04:40:45'),(30,39,'other_files','US10870580.pdf','other_files_6267e872793e443790eaaa9b98019584.pdf','2025/11/temp/other_files_6267e872793e443790eaaa9b98019584.pdf',1774521,'pdf','application/pdf',1,'2025-11-30 04:40:52'),(31,39,'carbon_loading_photo','微信图片_20250812133520.jpg','carbon_loading_photo_db060cc39bf5430abe5df331e4bb213b.jpg','2025/11/temp/carbon_loading_photo_db060cc39bf5430abe5df331e4bb213b.jpg',239957,'jpg','image/jpeg',1,'2025-11-30 04:53:46'),(32,39,'carbon_sample_photo','sasd.jpg','carbon_sample_photo_2940be38498e40998942bb8c1533b3c7.jpg','2025/11/temp/carbon_sample_photo_2940be38498e40998942bb8c1533b3c7.jpg',112905,'jpg','image/jpeg',1,'2025-11-30 04:53:53'),(33,39,'carbon_other_params','US10870580.pdf','carbon_other_params_d85a2b6ad62f42759e61812f4b9b7a38.pdf','2025/11/temp/carbon_other_params_d85a2b6ad62f42759e61812f4b9b7a38.pdf',1774521,'pdf','application/pdf',1,'2025-11-30 04:54:06'),(34,39,'carbon_loading_photo','pj.JPG','carbon_loading_photo_d3d0a48696294228a34f41bfb85afd52.jpg','2025/11/temp/carbon_loading_photo_d3d0a48696294228a34f41bfb85afd52.jpg',66619,'jpg','image/jpeg',1,'2025-11-30 05:12:44'),(35,39,'carbon_loading_photo','pj.JPG','carbon_loading_photo_bb98dd27c35b4e20a3bd462a79da44cd.jpg','2025/11/temp/carbon_loading_photo_bb98dd27c35b4e20a3bd462a79da44cd.jpg',66619,'jpg','image/jpeg',1,'2025-11-30 05:14:42'),(36,39,'carbon_sample_photo','sasd.jpg','carbon_sample_photo_44280e37a7a54b9fbc0799c41ecd7687.jpg','2025/11/temp/carbon_sample_photo_44280e37a7a54b9fbc0799c41ecd7687.jpg',112905,'jpg','image/jpeg',1,'2025-11-30 05:14:46'),(37,39,'carbon_other_params','US10870580.pdf','carbon_other_params_08b9e97bf8a845e3b4766cb5cef35da5.pdf','2025/11/temp/carbon_other_params_08b9e97bf8a845e3b4766cb5cef35da5.pdf',1774521,'pdf','application/pdf',1,'2025-11-30 05:14:50'),(38,39,'carbon_loading_photo','DJI_0486.JPG','carbon_loading_photo_bb17e5c71701494c8f16826c28b0777d.jpg','2025/12/temp/carbon_loading_photo_bb17e5c71701494c8f16826c28b0777d.jpg',1295015,'jpg','image/jpeg',1,'2025-12-01 03:43:49'),(39,39,'carbon_sample_photo','DJI_0508.JPG','carbon_sample_photo_301701b87a744db2b5ae275d75eabff8.jpg','2025/12/temp/carbon_sample_photo_301701b87a744db2b5ae275d75eabff8.jpg',1540936,'jpg','image/jpeg',1,'2025-12-01 03:43:56'),(40,39,'carbon_other_params','简历.docx','carbon_other_params_3ba8418fb98843cf92e5fabb7362561b.docx','2025/12/temp/carbon_other_params_3ba8418fb98843cf92e5fabb7362561b.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-01 03:44:06'),(41,39,'graphite_loading_photo','DJI_0489.JPG','graphite_loading_photo_3a72d1cc588441949e3835f3df6a51e0.jpg','2025/12/temp/graphite_loading_photo_3a72d1cc588441949e3835f3df6a51e0.jpg',1598619,'jpg','image/jpeg',1,'2025-12-01 03:46:09'),(42,39,'carbon_loading_photo','tc.JPG','carbon_loading_photo_7aefa5a348d347bcaac799919fa9579e.jpg','2025/12/temp/carbon_loading_photo_7aefa5a348d347bcaac799919fa9579e.jpg',43838,'jpg','image/jpeg',1,'2025-12-01 04:48:35'),(43,39,'carbon_sample_photo','OUTPUT.JPG','carbon_sample_photo_9da0535ae37d42df9cc5f3805b1cdaf0.jpg','2025/12/temp/carbon_sample_photo_9da0535ae37d42df9cc5f3805b1cdaf0.jpg',46974,'jpg','image/jpeg',1,'2025-12-01 04:48:40'),(44,39,'carbon_other_params','EP2636643A1.pdf','carbon_other_params_b25f609cf4794cfaada3e210537f7e43.pdf','2025/12/temp/carbon_other_params_b25f609cf4794cfaada3e210537f7e43.pdf',314565,'pdf','application/pdf',1,'2025-12-01 04:49:00'),(45,39,'graphite_loading_photo','tt1.jpg','graphite_loading_photo_d57e112978574706a578d38c3dcaa877.jpg','2025/12/temp/graphite_loading_photo_d57e112978574706a578d38c3dcaa877.jpg',114508,'jpg','image/jpeg',1,'2025-12-01 04:49:24'),(46,39,'graphite_sample_photo','tt1.jpg','graphite_sample_photo_595981be407d4eb38d0b1de61577fd31.jpg','2025/12/temp/graphite_sample_photo_595981be407d4eb38d0b1de61577fd31.jpg',114508,'jpg','image/jpeg',1,'2025-12-01 04:49:28'),(47,42,'carbon_loading_photo','DJI_0490.JPG','carbon_loading_photo_8619ce41ac1f45dbabac409a6ec48195.jpg','2025/12/temp/carbon_loading_photo_8619ce41ac1f45dbabac409a6ec48195.jpg',1318654,'jpg','image/jpeg',1,'2025-12-02 04:55:22'),(48,42,'carbon_other_params','简历.docx','carbon_other_params_8501e3b1a50e47f2bfc6f89d154b08b2.docx','2025/12/temp/carbon_other_params_8501e3b1a50e47f2bfc6f89d154b08b2.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-02 04:55:27'),(49,42,'graphite_loading_photo','DJI_0506.JPG','graphite_loading_photo_d0561f750f974572a4a7918223e30d76.jpg','2025/12/temp/graphite_loading_photo_d0561f750f974572a4a7918223e30d76.jpg',1780250,'jpg','image/jpeg',1,'2025-12-02 04:55:41'),(50,42,'graphite_other_params','简历.docx','graphite_other_params_bff152d17b124d7baed456f0e3611a4d.docx','2025/12/temp/graphite_other_params_bff152d17b124d7baed456f0e3611a4d.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-02 04:55:47'),(51,42,'appearance_defect_photo','DJI_0490.JPG','appearance_defect_photo_c2f655bd55354d42801dd721213a074b.jpg','2025/12/temp/appearance_defect_photo_c2f655bd55354d42801dd721213a074b.jpg',1318654,'jpg','image/jpeg',1,'2025-12-02 04:55:58'),(52,42,'appearance_defect_photo','DJI_0492.JPG','appearance_defect_photo_cb6fa1fb2d3d45baa397b1346e96542f.jpg','2025/12/temp/appearance_defect_photo_cb6fa1fb2d3d45baa397b1346e96542f.jpg',1347221,'jpg','image/jpeg',1,'2025-12-02 05:30:19'),(53,42,'sample_photo','DJI_0508.JPG','sample_photo_589dd5998eb04d42840b790e9992d21e.jpg','2025/12/temp/sample_photo_589dd5998eb04d42840b790e9992d21e.jpg',1540936,'jpg','image/jpeg',1,'2025-12-02 05:30:23'),(54,42,'carbon_sample_photo','DJI_0486.JPG','carbon_sample_photo_3cb8f5b4c3764de6948d9a8607124810.jpg','2025/12/temp/carbon_sample_photo_3cb8f5b4c3764de6948d9a8607124810.jpg',1295015,'jpg','image/jpeg',1,'2025-12-02 05:31:40'),(55,42,'carbon_other_params','简历.docx','carbon_other_params_c8d26b37aaee4ea3ab801e976575c621.docx','2025/12/temp/carbon_other_params_c8d26b37aaee4ea3ab801e976575c621.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-02 05:31:46'),(56,42,'carbon_loading_photo','DJI_0489.JPG','carbon_loading_photo_f56919122a864a52a5c364969f7d244f.jpg','2025/12/temp/carbon_loading_photo_f56919122a864a52a5c364969f7d244f.jpg',1598619,'jpg','image/jpeg',1,'2025-12-02 05:31:51'),(57,42,'graphite_loading_photo','DJI_0489.JPG','graphite_loading_photo_fc412c95a6cc428290a183687548265e.jpg','2025/12/temp/graphite_loading_photo_fc412c95a6cc428290a183687548265e.jpg',1598619,'jpg','image/jpeg',1,'2025-12-02 05:55:48'),(58,42,'carbon_loading_photo','DJI_0506.JPG','carbon_loading_photo_9030e579a5954801b2320e06c21c6192.jpg','2025/12/temp/carbon_loading_photo_9030e579a5954801b2320e06c21c6192.jpg',1780250,'jpg','image/jpeg',1,'2025-12-02 05:57:42'),(59,42,'carbon_sample_photo','DJI_0489.JPG','carbon_sample_photo_f2aaea6f444e4cf4acfba95e673a70ed.jpg','2025/12/temp/carbon_sample_photo_f2aaea6f444e4cf4acfba95e673a70ed.jpg',1598619,'jpg','image/jpeg',1,'2025-12-02 05:57:46'),(60,42,'carbon_other_params','简历.docx','carbon_other_params_5aa8c49a64da470bb2d6e1eadfafb8ce.docx','2025/12/temp/carbon_other_params_5aa8c49a64da470bb2d6e1eadfafb8ce.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-02 05:57:50'),(61,45,'carbon_loading_photo','DJI_0489.JPG','carbon_loading_photo_3ded77f7bb374365a094de192308712f.jpg','2025/12/temp/carbon_loading_photo_3ded77f7bb374365a094de192308712f.jpg',1598619,'jpg','image/jpeg',1,'2025-12-04 04:45:33'),(62,45,'carbon_sample_photo','DJI_0508.JPG','carbon_sample_photo_7dad12e0ba974184b0ea5988a17d79a6.jpg','2025/12/temp/carbon_sample_photo_7dad12e0ba974184b0ea5988a17d79a6.jpg',1540936,'jpg','image/jpeg',1,'2025-12-04 04:45:38'),(63,45,'carbon_other_params','简历.docx','carbon_other_params_20251600a96d424fb4018925c7208711.docx','2025/12/temp/carbon_other_params_20251600a96d424fb4018925c7208711.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-04 04:45:47'),(64,45,'carbon_loading_photo','DJI_0492.JPG','carbon_loading_photo_083d670676b9476594b03d03925ff4e4.jpg','2025/12/temp/carbon_loading_photo_083d670676b9476594b03d03925ff4e4.jpg',1347221,'jpg','image/jpeg',1,'2025-12-05 03:10:19'),(65,45,'carbon_sample_photo','DJI_0506.JPG','carbon_sample_photo_ebbe3c5851f14be68157a7d8d2e5d411.jpg','2025/12/temp/carbon_sample_photo_ebbe3c5851f14be68157a7d8d2e5d411.jpg',1780250,'jpg','image/jpeg',1,'2025-12-05 03:10:27'),(66,45,'carbon_other_params','简历.docx','carbon_other_params_f0fffe224775485aa2a9284f6d8d384f.docx','2025/12/temp/carbon_other_params_f0fffe224775485aa2a9284f6d8d384f.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-05 03:10:31'),(67,45,'graphite_loading_photo','DJI_0490.JPG','graphite_loading_photo_344c8b241926474a9aaf98c0378a5421.jpg','2025/12/temp/graphite_loading_photo_344c8b241926474a9aaf98c0378a5421.jpg',1318654,'jpg','image/jpeg',1,'2025-12-05 03:10:39'),(68,45,'graphite_sample_photo','DJI_0516.JPG','graphite_sample_photo_ed613b0f53ec412fa2ac1fbb0f7e2a74.jpg','2025/12/temp/graphite_sample_photo_ed613b0f53ec412fa2ac1fbb0f7e2a74.jpg',1176123,'jpg','image/jpeg',1,'2025-12-05 03:10:44'),(69,45,'graphite_other_params','简历.docx','graphite_other_params_db5d219656be4351b11982c2fd33c4b3.docx','2025/12/temp/graphite_other_params_db5d219656be4351b11982c2fd33c4b3.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-05 03:10:48'),(70,45,'appearance_defect_photo','DJI_0491.JPG','appearance_defect_photo_fa7a5628db7c4ab88188dfa9f3935c65.jpg','2025/12/temp/appearance_defect_photo_fa7a5628db7c4ab88188dfa9f3935c65.jpg',1181156,'jpg','image/jpeg',1,'2025-12-05 03:11:00'),(71,45,'carbon_loading_photo','DJI_0485.JPG','carbon_loading_photo_8f67854e75cb49b9a997909468c9dba2.jpg','2025/12/temp/carbon_loading_photo_8f67854e75cb49b9a997909468c9dba2.jpg',1520098,'jpg','image/jpeg',1,'2025-12-05 03:46:38'),(72,45,'carbon_other_params','简历.docx','carbon_other_params_7e3ee4d8949f484c80610bf3a1876a02.docx','2025/12/temp/carbon_other_params_7e3ee4d8949f484c80610bf3a1876a02.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-05 03:46:42'),(73,45,'graphite_loading_photo','TCB.JPG','graphite_loading_photo_7863ef00bcb44d16be0bffd9ebcdbe0f.jpg','2025/12/temp/graphite_loading_photo_7863ef00bcb44d16be0bffd9ebcdbe0f.jpg',278362,'jpg','image/jpeg',1,'2025-12-05 03:47:00'),(74,45,'appearance_defect_photo','DJI_0499.JPG','appearance_defect_photo_aee11aa1b14544e580304488bda15233.jpg','2025/12/temp/appearance_defect_photo_aee11aa1b14544e580304488bda15233.jpg',1379034,'jpg','image/jpeg',1,'2025-12-05 03:47:07'),(75,45,'appearance_defect_photo','TCB.JPG','appearance_defect_photo_f0de81067a3b435e9d32cb0b14a5df54.jpg','2025/12/temp/appearance_defect_photo_f0de81067a3b435e9d32cb0b14a5df54.jpg',278362,'jpg','image/jpeg',1,'2025-12-05 03:54:09'),(76,45,'sample_photo','TCB.JPG','sample_photo_81b8c4ef37b644c39c0c55530e3709b4.jpg','2025/12/temp/sample_photo_81b8c4ef37b644c39c0c55530e3709b4.jpg',278362,'jpg','image/jpeg',1,'2025-12-05 03:54:13'),(77,45,'other_files','US5091025.pdf','other_files_220e499788b84b36b50a5cb336bf3f79.pdf','2025/12/temp/other_files_220e499788b84b36b50a5cb336bf3f79.pdf',755860,'pdf','application/pdf',1,'2025-12-05 03:54:46'),(78,46,'carbon_sample_photo','DJI_0499.JPG','carbon_sample_photo_a1e7b2af21ef4f78b75eff2d4c69a345.jpg','2025/12/temp/carbon_sample_photo_a1e7b2af21ef4f78b75eff2d4c69a345.jpg',1379034,'jpg','image/jpeg',1,'2025-12-05 04:27:30'),(79,46,'carbon_other_params','DJI_0489.JPG','carbon_other_params_4cb4f6e308e345e3a1954ea4bbf88644.jpg','2025/12/temp/carbon_other_params_4cb4f6e308e345e3a1954ea4bbf88644.jpg',1598619,'jpg','image/jpeg',1,'2025-12-05 04:27:34'),(80,46,'carbon_other_params','简历.docx','carbon_other_params_28ee18cf0d314a5c9625c28f5c380d89.docx','2025/12/temp/carbon_other_params_28ee18cf0d314a5c9625c28f5c380d89.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-05 04:27:41'),(81,46,'carbon_loading_photo','DJI_0489.JPG','carbon_loading_photo_f496fc15a9ee4510842ff9b4287c81c7.jpg','2025/12/temp/carbon_loading_photo_f496fc15a9ee4510842ff9b4287c81c7.jpg',1598619,'jpg','image/jpeg',1,'2025-12-05 04:27:44'),(82,46,'carbon_loading_photo','DJI_0499.JPG','carbon_loading_photo_044b2b4b659445ecbf962cfe4817cf9c.jpg','2025/12/temp/carbon_loading_photo_044b2b4b659445ecbf962cfe4817cf9c.jpg',1379034,'jpg','image/jpeg',1,'2025-12-05 04:28:50'),(83,46,'carbon_sample_photo','DJI_0489.JPG','carbon_sample_photo_839e162484eb4e8bb99a855d833c9db4.jpg','2025/12/temp/carbon_sample_photo_839e162484eb4e8bb99a855d833c9db4.jpg',1598619,'jpg','image/jpeg',1,'2025-12-05 04:28:55'),(84,46,'carbon_other_params','简历.docx','carbon_other_params_ee20b3ac7e4942ed8fc1b1e71e70e3e6.docx','2025/12/temp/carbon_other_params_ee20b3ac7e4942ed8fc1b1e71e70e3e6.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-05 04:28:57'),(85,47,'carbon_loading_photo','TCB.JPG','carbon_loading_photo_0ece1203ef0c4e6681840a701b3ab268.jpg','2025/12/temp/carbon_loading_photo_0ece1203ef0c4e6681840a701b3ab268.jpg',278362,'jpg','image/jpeg',1,'2025-12-06 00:58:32'),(86,47,'carbon_sample_photo','TCB.JPG','carbon_sample_photo_d22723c57a5145d392fe6c32bf742cff.jpg','2025/12/temp/carbon_sample_photo_d22723c57a5145d392fe6c32bf742cff.jpg',278362,'jpg','image/jpeg',1,'2025-12-06 00:58:39'),(87,47,'carbon_other_params','简历.docx','carbon_other_params_e0d6526341c44079a02f1a236123c3c5.docx','2025/12/temp/carbon_other_params_e0d6526341c44079a02f1a236123c3c5.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1,'2025-12-06 00:58:49'),(88,47,'graphite_loading_photo','TCB.JPG','graphite_loading_photo_ce71fb706dfe42dd9a5c14c66fc232c6.jpg','2025/12/temp/graphite_loading_photo_ce71fb706dfe42dd9a5c14c66fc232c6.jpg',278362,'jpg','image/jpeg',1,'2025-12-06 00:58:56'),(89,47,'appearance_defect_photo','TCB.JPG','appearance_defect_photo_5b0fee8c3b1641f59f4971adc3d3691f.jpg','2025/12/temp/appearance_defect_photo_5b0fee8c3b1641f59f4971adc3d3691f.jpg',278362,'jpg','image/jpeg',1,'2025-12-06 00:59:07'),(90,49,'graphite_loading_photo','DJI_0489.JPG','graphite_loading_photo_3bbc2cebd8224566898c945e3fec1c89.jpg','2025/12/temp/graphite_loading_photo_3bbc2cebd8224566898c945e3fec1c89.jpg',1598619,'jpg','image/jpeg',4,'2025-12-09 16:28:48'),(91,49,'graphite_sample_photo','DJI_0499.JPG','graphite_sample_photo_ddc0d0531c2b4b8f9f22e5f95b26286c.jpg','2025/12/temp/graphite_sample_photo_ddc0d0531c2b4b8f9f22e5f95b26286c.jpg',1379034,'jpg','image/jpeg',4,'2025-12-09 16:29:00'),(92,49,'carbon_sample_photo','DJI_0486.JPG','carbon_sample_photo_0d432c40698c4be29a6ab6de9971abfd.jpg','2025/12/temp/carbon_sample_photo_0d432c40698c4be29a6ab6de9971abfd.jpg',1295015,'jpg','image/jpeg',4,'2025-12-09 16:30:03'),(93,56,'carbon_sample_photo','DJI_0489.JPG','carbon_sample_photo_0ae8dc0a1699450dbb1f88d62d14d811.jpg','2025/12/temp/carbon_sample_photo_0ae8dc0a1699450dbb1f88d62d14d811.jpg',1598619,'jpg','image/jpeg',1,'2025-12-11 04:19:06'),(94,56,'carbon_sample_photo','DJI_0486.JPG','carbon_sample_photo_4016c23c68f04658aeef78784e970f20.jpg','2025/12/temp/carbon_sample_photo_4016c23c68f04658aeef78784e970f20.jpg',1295015,'jpg','image/jpeg',1,'2025-12-11 04:20:37'),(95,57,'carbon_sample_photo','DJI_0506.JPG','carbon_sample_photo_1e2aba5b571a42f185d751795d208801.jpg','2025/12/temp/carbon_sample_photo_1e2aba5b571a42f185d751795d208801.jpg',1780250,'jpg','image/jpeg',4,'2025-12-11 04:21:59'),(96,57,'carbon_loading_photo','DJI_0508.JPG','carbon_loading_photo_a6b6fef981cc4a86b5f627fb4f70c265.jpg','2025/12/temp/carbon_loading_photo_a6b6fef981cc4a86b5f627fb4f70c265.jpg',1540936,'jpg','image/jpeg',4,'2025-12-11 04:31:53'),(97,57,'carbon_other_params','简历.docx','carbon_other_params_285d7b387c824be3b86fa801511669e7.docx','2025/12/temp/carbon_other_params_285d7b387c824be3b86fa801511669e7.docx',18114,'docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',4,'2025-12-11 04:31:59');
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
) ENGINE=InnoDB AUTO_INCREMENT=358 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='绯荤粺鎿嶄綔鏃ュ織琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
INSERT INTO `system_logs` VALUES (1,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6328','2025-09-22 05:30:49'),(2,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-01 00:55:27'),(3,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6328','2025-10-07 00:31:53'),(4,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 00:47:18'),(5,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 05:46:59'),(6,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 07:02:43'),(7,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 17:29:39'),(8,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 02:52:24'),(9,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 03:34:31'),(10,1,'save_draft','experiment',1,'保存草稿 100ISA-TH5100-251008DG-RIF01','127.0.0.1',NULL,'2025-10-08 04:38:55'),(11,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 03:38:24'),(12,1,'save_draft','experiment',2,'保存草稿 75DHW-THK43-251009DG-RIF01','127.0.0.1',NULL,'2025-10-09 03:38:46'),(13,1,'save_draft','experiment',3,'保存草稿 100ISA-TH5100-251008DG-RIF02','127.0.0.1',NULL,'2025-10-09 03:40:42'),(14,1,'save_draft','experiment',4,'保存草稿 25IRD-GH38-251009DG-RIF01','127.0.0.1',NULL,'2025-10-09 03:52:10'),(15,1,'save_draft','experiment',5,'保存草稿 25IRD-GH38-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:18:58'),(16,1,'update_draft','experiment',5,'更新草稿 25IRD-GH38-251009DG-ROF02','127.0.0.1',NULL,'2025-10-09 04:19:08'),(17,1,'save_draft','experiment',6,'保存草稿 75ISA-GH75-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:46:47'),(18,1,'update_draft','experiment',6,'更新草稿 50ISA-NA50-251009DG-RIF02','127.0.0.1',NULL,'2025-10-09 04:47:20'),(19,1,'update_draft','experiment',6,'更新草稿 50ISA-NA50-251009DG-ROF02','127.0.0.1',NULL,'2025-10-09 04:47:32'),(20,1,'save_draft','experiment',7,'保存草稿 25IRD-GP43-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:21:19'),(21,1,'update_draft','experiment',7,'更新草稿 50IRD-GH50-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:21:31'),(22,1,'update_draft','experiment',7,'更新草稿 50IRD-GH50-251008DG-RIF01','127.0.0.1',NULL,'2025-10-09 05:22:59'),(23,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 04:25:17'),(24,1,'save_draft','experiment',8,'保存草稿 50ISA-GH50-251010DG-RIF02','127.0.0.1',NULL,'2025-10-10 04:25:59'),(25,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:26:17'),(26,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:26:28'),(27,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:27:18'),(28,1,'update_draft','experiment',8,'更新草稿 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-10-10 04:27:58'),(29,1,'save_draft','experiment',11,'保存草稿 75NRD-GH38-251010DG-RIR08','127.0.0.1',NULL,'2025-10-10 05:00:03'),(30,1,'submit_experiment','experiment',12,'提交实验 75NRD-GH38-251010DG-RIR13','127.0.0.1',NULL,'2025-10-10 05:02:16'),(31,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 03:18:46'),(32,1,'save_draft','experiment',13,'保存草稿 55DTM-THK55-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 03:19:21'),(33,1,'update_draft','experiment',13,'更新草稿 55DTM-THK55-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 03:21:04'),(34,1,'submit_experiment','experiment',14,'提交实验 55DTM-THK55-251012DG-RIF02','127.0.0.1',NULL,'2025-10-12 03:21:50'),(35,1,'save_draft','experiment',15,'保存草稿 25ISA-GH38-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 04:19:41'),(36,1,'submit_experiment','experiment',18,'提交实验 50DBY-THK43-251012DG-RIF01','127.0.0.1',NULL,'2025-10-12 04:23:24'),(37,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-14 00:30:32'),(38,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:01:35'),(39,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:15'),(40,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:28'),(41,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 03:06:44'),(42,1,'save_draft','experiment',19,'保存草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:10:53'),(43,1,'update_draft','experiment',19,'更新草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:11:52'),(44,1,'update_draft','experiment',19,'更新草稿 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:12:22'),(45,1,'submit_experiment','experiment',19,'提交实验 25IRD-GH38-251016DG-RIF02','127.0.0.1',NULL,'2025-10-16 03:12:31'),(46,1,'save_draft','experiment',20,'保存草稿 25IMP-GH38-251016DG-RIF01','127.0.0.1',NULL,'2025-10-16 04:30:49'),(47,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 21:43:26'),(48,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 21:44:14'),(49,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 21:44:51'),(50,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.16.0','2025-10-16 23:22:27'),(51,1,'save_draft','experiment',21,'保存草稿 25IRD-GP43-251017DG-RIF01','127.0.0.1',NULL,'2025-10-16 23:24:31'),(52,1,'save_draft','experiment',22,'保存草稿 25IRD-GH38-251014DG-RIF02','127.0.0.1',NULL,'2025-10-17 01:15:48'),(53,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-20 04:29:23'),(54,1,'save_draft','experiment',23,'保存草稿 25IRD-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:42:45'),(55,1,'save_draft','experiment',24,'保存草稿 25ISA-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:44:14'),(56,1,'save_draft','experiment',25,'保存草稿 25DRD-GP43-251020DG-RIF01','127.0.0.1',NULL,'2025-10-20 04:46:11'),(57,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-20 05:38:25'),(58,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-21 05:15:05'),(59,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 02:14:51'),(60,1,'delete_experiment','experiment',20,'删除实验 25IMP-GH38-251016DG-RIF01','127.0.0.1',NULL,'2025-10-27 02:15:18'),(61,1,'delete_experiment','experiment',6,'删除实验 50ISA-NA50-251009DG-ROF02','127.0.0.1',NULL,'2025-10-27 02:41:13'),(62,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 03:20:01'),(63,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-27 03:27:11'),(64,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 02:50:59'),(65,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 02:51:08'),(66,1,'delete_experiment','experiment',4,'删除实验 25IRD-GH38-251009DG-RIF01','127.0.0.1',NULL,'2025-10-28 02:51:48'),(67,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 03:59:18'),(68,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-28 21:41:50'),(69,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-29 22:57:49'),(70,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-31 05:54:30'),(71,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-31 05:57:45'),(72,1,'submit_experiment','experiment',26,'提交实验 55ISA-THK43-251031DX-RIF01','127.0.0.1',NULL,'2025-10-31 06:00:01'),(73,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 06:37:16'),(74,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 06:37:24'),(75,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 18:25:16'),(76,1,'save_draft','experiment',27,'保存草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-01 18:39:23'),(77,1,'save_draft','experiment',28,'保存草稿 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:41:11'),(78,1,'update_draft','experiment',28,'更新草稿 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:44:01'),(79,1,'submit_experiment','experiment',28,'提交实验 55NRD-GH150-251102XT-RIR01','127.0.0.1',NULL,'2025-11-01 18:54:01'),(80,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-01 22:35:03'),(81,1,'save_draft','experiment',29,'保存草稿 55NRD-THK55-251102WF-RIF01','127.0.0.1',NULL,'2025-11-01 22:41:35'),(82,1,'submit_experiment','experiment',29,'提交实验 55NRD-THK55-251102WF-RIF01','127.0.0.1',NULL,'2025-11-01 22:47:32'),(83,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-02 00:38:49'),(84,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:45:43'),(85,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:46:32'),(86,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:46:46'),(87,1,'update_draft','experiment',27,'更新草稿 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-11-02 04:48:01'),(88,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-03 05:29:11'),(89,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-06 00:16:44'),(90,1,'login_failed',NULL,NULL,'用户 admin 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-11-06 00:40:57'),(91,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 19:25:58'),(92,NULL,'login_failed',NULL,NULL,'用户 engineer 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 21:44:12'),(93,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-12 21:44:23'),(94,NULL,'login_failed',NULL,NULL,'用户 engineer  登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:29'),(95,1,'login_success',NULL,NULL,'用户 admin  登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:38'),(96,NULL,'login_failed',NULL,NULL,'用户 user 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:40:53'),(97,NULL,'login_failed',NULL,NULL,'用户 user 登录失败','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 04:51:39'),(98,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 03:44:43'),(99,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:16:50'),(100,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:31:53'),(101,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:07'),(102,5,'login_failed',NULL,NULL,'用户 user 登录失败 - 密码错误','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:23'),(103,5,'login_success',NULL,NULL,'用户 user 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:41:31'),(104,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-21 04:49:28'),(105,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 03:32:49'),(106,1,'save_draft','experiment',30,'保存草稿 25IRD-GP43-251123DG-RIF01','127.0.0.1',NULL,'2025-11-23 03:34:03'),(107,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-24 04:57:46'),(108,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-24 05:25:55'),(109,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-24 06:03:35'),(110,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-29 17:55:32'),(111,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-30 00:27:14'),(112,1,'save_draft','experiment',31,'保存草稿 25IRD-GP43-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 00:27:44'),(113,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-30 00:55:11'),(114,1,'save_draft','experiment',32,'保存草稿 25IRD-GH38-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 00:55:47'),(115,1,'upload_file','file',1,'上传文件: qq.JPG','127.0.0.1',NULL,'2025-11-30 00:55:55'),(116,1,'upload_file','file',2,'上传文件: DJI_0506.JPG','127.0.0.1',NULL,'2025-11-30 00:56:17'),(117,1,'upload_file','file',3,'上传文件: DJI_0490.JPG','127.0.0.1',NULL,'2025-11-30 00:56:51'),(118,1,'upload_file','file',4,'上传文件: DJI_0490.JPG','127.0.0.1',NULL,'2025-11-30 00:56:59'),(119,1,'upload_file','file',5,'上传文件: EP2636643A1.pdf','127.0.0.1',NULL,'2025-11-30 00:57:09'),(120,1,'upload_file','file',6,'上传文件: 20250812211528.png','127.0.0.1',NULL,'2025-11-30 00:57:36'),(121,1,'upload_file','file',7,'上传文件: DJI_0492.JPG','127.0.0.1',NULL,'2025-11-30 00:57:57'),(122,1,'upload_file','file',8,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-11-30 00:58:04'),(123,1,'upload_file','file',9,'上传文件: US5091025.pdf','127.0.0.1',NULL,'2025-11-30 00:58:29'),(124,1,'update_draft','experiment',32,'更新草稿 25IRD-GH38-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 00:58:43'),(125,1,'update_draft','experiment',32,'更新草稿 25IRD-GH38-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 01:08:41'),(126,1,'save_draft','experiment',33,'保存草稿 25IRD-GH38-251130DG-ROR01','127.0.0.1',NULL,'2025-11-30 01:12:18'),(127,1,'update_draft','experiment',33,'更新草稿 25IRD-GH38-251130DG-ROR01','127.0.0.1',NULL,'2025-11-30 01:12:56'),(128,1,'upload_file','file',10,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-11-30 01:13:16'),(129,1,'upload_file','file',11,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-11-30 01:13:22'),(130,1,'update_draft','experiment',33,'更新草稿 25IRD-GH38-251130DG-ROR01','127.0.0.1',NULL,'2025-11-30 01:13:41'),(131,1,'upload_file','file',12,'上传文件: US5091025.pdf','127.0.0.1',NULL,'2025-11-30 02:54:07'),(132,1,'save_draft','experiment',34,'保存草稿 25IRD-GH38-251130XT-RIR01','127.0.0.1',NULL,'2025-11-30 03:27:22'),(133,1,'upload_file','file',13,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-11-30 03:27:32'),(134,1,'upload_file','file',14,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-11-30 03:27:45'),(135,1,'upload_file','file',15,'上传文件: 肖博宇简历.docx','127.0.0.1',NULL,'2025-11-30 03:27:53'),(136,1,'save_draft','experiment',35,'保存草稿 25NMP-THK43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:10:14'),(137,1,'upload_file','file',16,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-11-30 04:10:21'),(138,1,'upload_file','file',17,'上传文件: DJI_0509.JPG','127.0.0.1',NULL,'2025-11-30 04:10:30'),(139,1,'upload_file','file',18,'上传文件: 肖博宇简历.docx','127.0.0.1',NULL,'2025-11-30 04:10:43'),(140,1,'upload_file','file',19,'上传文件: 分卷.xlsx','127.0.0.1',NULL,'2025-11-30 04:13:14'),(141,1,'update_draft','experiment',35,'更新草稿 25NMP-THK43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:14:03'),(142,1,'upload_file','file',20,'上传文件: EP2636643A1.pdf','127.0.0.1',NULL,'2025-11-30 04:15:04'),(143,1,'upload_file','file',21,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-11-30 04:15:12'),(144,1,'update_draft','experiment',35,'更新草稿 25NMP-THK43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:15:18'),(145,1,'update_draft','experiment',35,'更新草稿 25NMP-THK43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:17:25'),(146,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-30 04:37:44'),(147,1,'delete_experiment','experiment',35,'删除实验 25NMP-THK43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:38:14'),(148,1,'delete_experiment','experiment',34,'删除实验 25IRD-GH38-251130XT-RIR01','127.0.0.1',NULL,'2025-11-30 04:38:17'),(149,1,'delete_experiment','experiment',33,'删除实验 25IRD-GH38-251130DG-ROR01','127.0.0.1',NULL,'2025-11-30 04:38:21'),(150,1,'delete_experiment','experiment',32,'删除实验 25IRD-GH38-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 04:38:24'),(151,1,'delete_experiment','experiment',31,'删除实验 25IRD-GP43-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 04:38:27'),(152,1,'save_draft','experiment',36,'保存草稿 25NMP-GP43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:38:59'),(153,1,'upload_file','file',22,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-11-30 04:39:06'),(154,1,'upload_file','file',23,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-11-30 04:39:15'),(155,1,'upload_file','file',24,'上传文件: 肖博宇简历.docx','127.0.0.1',NULL,'2025-11-30 04:39:21'),(156,1,'update_draft','experiment',36,'更新草稿 25NMP-GP43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:39:44'),(157,1,'upload_file','file',25,'上传文件: DJI_0492.JPG','127.0.0.1',NULL,'2025-11-30 04:39:53'),(158,1,'upload_file','file',26,'上传文件: DJI_0491.JPG','127.0.0.1',NULL,'2025-11-30 04:39:58'),(159,1,'upload_file','file',27,'上传文件: US5091025.pdf','127.0.0.1',NULL,'2025-11-30 04:40:07'),(160,1,'update_draft','experiment',36,'更新草稿 25NMP-GP43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:40:23'),(161,1,'upload_file','file',28,'上传文件: 微信图片_20250812211528.png','127.0.0.1',NULL,'2025-11-30 04:40:35'),(162,1,'upload_file','file',29,'上传文件: 微信图片_20250812133520.jpg','127.0.0.1',NULL,'2025-11-30 04:40:45'),(163,1,'upload_file','file',30,'上传文件: US10870580.pdf','127.0.0.1',NULL,'2025-11-30 04:40:52'),(164,1,'update_draft','experiment',36,'更新草稿 25NMP-GP43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:40:56'),(165,1,'upload_file','file',31,'上传文件: 微信图片_20250812133520.jpg','127.0.0.1',NULL,'2025-11-30 04:53:46'),(166,1,'upload_file','file',32,'上传文件: sasd.jpg','127.0.0.1',NULL,'2025-11-30 04:53:53'),(167,1,'upload_file','file',33,'上传文件: US10870580.pdf','127.0.0.1',NULL,'2025-11-30 04:54:06'),(168,1,'update_draft','experiment',36,'更新草稿 25NMP-GP43-251130XT-RIF01','127.0.0.1',NULL,'2025-11-30 04:54:24'),(169,1,'save_draft','experiment',37,'保存草稿 25IRD-GP43-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 05:12:14'),(170,1,'upload_file','file',34,'上传文件: pj.JPG','127.0.0.1',NULL,'2025-11-30 05:12:44'),(171,1,'update_draft','experiment',37,'更新草稿 25IRD-GP43-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 05:12:47'),(172,1,'upload_file','file',35,'上传文件: pj.JPG','127.0.0.1',NULL,'2025-11-30 05:14:42'),(173,1,'upload_file','file',36,'上传文件: sasd.jpg','127.0.0.1',NULL,'2025-11-30 05:14:46'),(174,1,'upload_file','file',37,'上传文件: US10870580.pdf','127.0.0.1',NULL,'2025-11-30 05:14:50'),(175,1,'update_draft','experiment',37,'更新草稿 25IRD-GP43-251130DG-RIF01','127.0.0.1',NULL,'2025-11-30 05:15:10'),(176,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-01 03:38:40'),(177,1,'save_draft','experiment',38,'保存草稿 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 03:43:27'),(178,1,'upload_file','file',38,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-12-01 03:43:49'),(179,1,'upload_file','file',39,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-12-01 03:43:56'),(180,1,'upload_file','file',40,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-01 03:44:06'),(181,1,'update_draft','experiment',38,'更新草稿 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 03:44:09'),(182,1,'update_draft','experiment',38,'更新草稿 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 03:45:30'),(183,1,'upload_file','file',41,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-01 03:46:09'),(184,1,'update_draft','experiment',38,'更新草稿 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 03:46:11'),(185,1,'update_draft','experiment',38,'更新草稿 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 03:46:49'),(186,1,'delete_experiment','experiment',38,'删除实验 25IRD-GH38-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 04:47:25'),(187,1,'save_draft','experiment',39,'保存草稿 25ISA-GP43-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 04:47:54'),(188,1,'upload_file','file',42,'上传文件: tc.JPG','127.0.0.1',NULL,'2025-12-01 04:48:35'),(189,1,'upload_file','file',43,'上传文件: OUTPUT.JPG','127.0.0.1',NULL,'2025-12-01 04:48:40'),(190,1,'upload_file','file',44,'上传文件: EP2636643A1.pdf','127.0.0.1',NULL,'2025-12-01 04:49:00'),(191,1,'update_draft','experiment',39,'更新草稿 25ISA-GP43-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 04:49:08'),(192,1,'upload_file','file',45,'上传文件: tt1.jpg','127.0.0.1',NULL,'2025-12-01 04:49:24'),(193,1,'upload_file','file',46,'上传文件: tt1.jpg','127.0.0.1',NULL,'2025-12-01 04:49:28'),(194,1,'update_draft','experiment',39,'更新草稿 25ISA-GP43-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 04:49:29'),(195,1,'update_draft','experiment',39,'更新草稿 25ISA-GP43-251201DG-RIF01','127.0.0.1',NULL,'2025-12-01 04:52:56'),(196,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-02 04:49:11'),(197,1,'save_draft','experiment',40,'保存草稿 25ISA-GH38-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 04:54:54'),(198,1,'upload_file','file',47,'上传文件: DJI_0490.JPG','127.0.0.1',NULL,'2025-12-02 04:55:22'),(199,1,'upload_file','file',48,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-02 04:55:27'),(200,1,'upload_file','file',49,'上传文件: DJI_0506.JPG','127.0.0.1',NULL,'2025-12-02 04:55:41'),(201,1,'upload_file','file',50,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-02 04:55:47'),(202,1,'upload_file','file',51,'上传文件: DJI_0490.JPG','127.0.0.1',NULL,'2025-12-02 04:55:58'),(203,1,'update_draft','experiment',40,'更新草稿 25ISA-GH38-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 04:56:03'),(204,1,'upload_file','file',52,'上传文件: DJI_0492.JPG','127.0.0.1',NULL,'2025-12-02 05:30:19'),(205,1,'upload_file','file',53,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-12-02 05:30:23'),(206,1,'save_draft','experiment',41,'保存草稿 25DBY-GP43-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:31:27'),(207,1,'upload_file','file',54,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-12-02 05:31:40'),(208,1,'upload_file','file',55,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-02 05:31:46'),(209,1,'upload_file','file',56,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-02 05:31:51'),(210,1,'update_draft','experiment',41,'更新草稿 25DBY-GP43-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:31:54'),(211,1,'upload_file','file',57,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-02 05:55:48'),(212,1,'update_draft','experiment',41,'更新草稿 25DBY-GP43-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:55:55'),(213,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-02 05:56:41'),(214,1,'delete_experiment','experiment',41,'删除实验 25DBY-GP43-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:56:59'),(215,1,'delete_experiment','experiment',40,'删除实验 25ISA-GH38-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:57:03'),(216,1,'upload_file','file',58,'上传文件: DJI_0506.JPG','127.0.0.1',NULL,'2025-12-02 05:57:42'),(217,1,'upload_file','file',59,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-02 05:57:46'),(218,1,'upload_file','file',60,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-02 05:57:50'),(219,1,'save_draft','experiment',42,'保存草稿 25IRD-GH38-251202DG-RIF01','127.0.0.1',NULL,'2025-12-02 05:57:53'),(220,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-04 04:05:05'),(221,1,'save_draft','experiment',43,'保存草稿 25ISA-THK43-251204DG-RIF01','127.0.0.1',NULL,'2025-12-04 04:45:14'),(222,1,'upload_file','file',61,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-04 04:45:33'),(223,1,'upload_file','file',62,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-12-04 04:45:39'),(224,1,'upload_file','file',63,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-04 04:45:47'),(225,1,'update_draft','experiment',43,'更新草稿 25ISA-THK43-251204DG-RIF01','127.0.0.1',NULL,'2025-12-04 04:45:49'),(226,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-05 02:53:27'),(227,1,'save_draft','experiment',44,'保存草稿 50ISA-GP43-251205XT-RIF01','127.0.0.1',NULL,'2025-12-05 03:09:53'),(228,1,'upload_file','file',64,'上传文件: DJI_0492.JPG','127.0.0.1',NULL,'2025-12-05 03:10:19'),(229,1,'upload_file','file',65,'上传文件: DJI_0506.JPG','127.0.0.1',NULL,'2025-12-05 03:10:28'),(230,1,'upload_file','file',66,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-05 03:10:31'),(231,1,'update_draft','experiment',44,'更新草稿 50ISA-GP43-251205XT-RIF01','127.0.0.1',NULL,'2025-12-05 03:10:33'),(232,1,'upload_file','file',67,'上传文件: DJI_0490.JPG','127.0.0.1',NULL,'2025-12-05 03:10:39'),(233,1,'upload_file','file',68,'上传文件: DJI_0516.JPG','127.0.0.1',NULL,'2025-12-05 03:10:44'),(234,1,'upload_file','file',69,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-05 03:10:49'),(235,1,'upload_file','file',70,'上传文件: DJI_0491.JPG','127.0.0.1',NULL,'2025-12-05 03:11:00'),(236,1,'update_draft','experiment',44,'更新草稿 50ISA-GP43-251205XT-RIF01','127.0.0.1',NULL,'2025-12-05 03:11:02'),(237,1,'update_draft','experiment',44,'更新草稿 50ISA-GP43-251205XT-RIF01','127.0.0.1',NULL,'2025-12-05 03:11:11'),(238,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-05 03:32:16'),(239,1,'delete_experiment','experiment',43,'删除实验 25ISA-THK43-251204DG-RIF01','127.0.0.1',NULL,'2025-12-05 03:45:33'),(240,1,'delete_experiment','experiment',44,'删除实验 50ISA-GP43-251205XT-RIF01','127.0.0.1',NULL,'2025-12-05 03:45:36'),(241,1,'save_draft','experiment',45,'保存草稿 25ISA-GP43-251205XT-PIF01','127.0.0.1',NULL,'2025-12-05 03:46:19'),(242,1,'upload_file','file',71,'上传文件: DJI_0485.JPG','127.0.0.1',NULL,'2025-12-05 03:46:38'),(243,1,'upload_file','file',72,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-05 03:46:42'),(244,1,'upload_file','file',73,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-05 03:47:00'),(245,1,'upload_file','file',74,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-12-05 03:47:07'),(246,1,'update_draft','experiment',45,'更新草稿 25ISA-GP43-251205XT-PIF01','127.0.0.1',NULL,'2025-12-05 03:47:14'),(247,1,'upload_file','file',75,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-05 03:54:09'),(248,1,'upload_file','file',76,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-05 03:54:13'),(249,1,'upload_file','file',77,'上传文件: US5091025.pdf','127.0.0.1',NULL,'2025-12-05 03:54:46'),(250,1,'update_draft','experiment',45,'更新草稿 25ISA-GP43-251205XT-PIF01','127.0.0.1',NULL,'2025-12-05 03:54:48'),(251,1,'submit_experiment','experiment',45,'提交实验 25ISA-GP43-251205XT-PIF01','127.0.0.1',NULL,'2025-12-05 03:55:17'),(252,1,'save_draft','experiment',46,'保存草稿 25ISA-THK55-251205WF-PIF01','127.0.0.1',NULL,'2025-12-05 04:27:12'),(253,1,'upload_file','file',78,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-12-05 04:27:30'),(254,1,'upload_file','file',79,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-05 04:27:34'),(255,1,'upload_file','file',80,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-05 04:27:41'),(256,1,'upload_file','file',81,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-05 04:27:44'),(257,1,'update_draft','experiment',46,'更新草稿 25ISA-THK55-251205WF-PIF01','127.0.0.1',NULL,'2025-12-05 04:27:46'),(258,1,'upload_file','file',82,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-12-05 04:28:50'),(259,1,'upload_file','file',83,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-05 04:28:55'),(260,1,'upload_file','file',84,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-05 04:28:57'),(261,1,'update_draft','experiment',46,'更新草稿 25ISA-THK55-251205WF-PIF01','127.0.0.1',NULL,'2025-12-05 04:29:04'),(262,1,'delete_experiment','experiment',1,'删除实验 100ISA-TH5100-251008DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:39:25'),(263,1,'delete_experiment','experiment',2,'删除实验 75DHW-THK43-251009DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:39:28'),(264,1,'delete_experiment','experiment',3,'删除实验 100ISA-TH5100-251008DG-RIF02','127.0.0.1',NULL,'2025-12-05 04:39:32'),(265,1,'delete_experiment','experiment',5,'删除实验 25IRD-GH38-251009DG-ROF02','127.0.0.1',NULL,'2025-12-05 04:39:35'),(266,1,'delete_experiment','experiment',7,'删除实验 50IRD-GH50-251008DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:08'),(267,1,'delete_experiment','experiment',8,'删除实验 50ISA-GH50-251010XT-RIR02','127.0.0.1',NULL,'2025-12-05 04:54:09'),(268,1,'delete_experiment','experiment',11,'删除实验 75NRD-GH38-251010DG-RIR08','127.0.0.1',NULL,'2025-12-05 04:54:12'),(269,1,'delete_experiment','experiment',13,'删除实验 55DTM-THK55-251012DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:14'),(270,1,'delete_experiment','experiment',15,'删除实验 25ISA-GH38-251012DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:20'),(271,1,'delete_experiment','experiment',21,'删除实验 25IRD-GP43-251017DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:23'),(272,1,'delete_experiment','experiment',22,'删除实验 25IRD-GH38-251014DG-RIF02','127.0.0.1',NULL,'2025-12-05 04:54:26'),(273,1,'delete_experiment','experiment',23,'删除实验 25IRD-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:29'),(274,1,'delete_experiment','experiment',24,'删除实验 25ISA-GH38-251020DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:32'),(275,1,'delete_experiment','experiment',30,'删除实验 25IRD-GP43-251123DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:35'),(276,1,'delete_experiment','experiment',27,'删除实验 50ISA-GH50-251102DG-RIF01','127.0.0.1',NULL,'2025-12-05 04:54:40'),(277,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 00:51:22'),(278,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 00:51:58'),(279,1,'save_draft','experiment',47,'保存草稿 75ISA-GH38-251206DG-ROF01','127.0.0.1',NULL,'2025-12-06 00:55:27'),(280,1,'upload_file','file',85,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-06 00:58:32'),(281,1,'upload_file','file',86,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-06 00:58:39'),(282,1,'upload_file','file',87,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-06 00:58:49'),(283,1,'upload_file','file',88,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-06 00:58:56'),(284,1,'upload_file','file',89,'上传文件: TCB.JPG','127.0.0.1',NULL,'2025-12-06 00:59:07'),(285,1,'update_draft','experiment',47,'更新草稿 75ISA-GH38-251206DG-ROF01','127.0.0.1',NULL,'2025-12-06 00:59:12'),(286,1,'update_draft','experiment',47,'更新草稿 75ISA-GH38-251206DG-ROF01','127.0.0.1',NULL,'2025-12-06 01:00:31'),(287,1,'update_draft','experiment',47,'更新草稿 75ISA-GH38-251206DG-ROF01','127.0.0.1',NULL,'2025-12-06 01:00:59'),(288,1,'update_draft','experiment',47,'更新草稿 75ISA-GH38-251206DG-ROF01','127.0.0.1',NULL,'2025-12-06 01:12:14'),(289,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 05:21:06'),(290,4,'save_draft','experiment',48,'保存草稿 25IRD-GH38-251206DG-RIF01','127.0.0.1',NULL,'2025-12-06 05:22:11'),(291,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 19:59:58'),(292,5,'login_success',NULL,NULL,'用户 user 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 20:10:26'),(293,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 22:30:09'),(294,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-06 22:30:40'),(295,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','curl/8.13.0','2025-12-07 01:32:25'),(296,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-07 02:02:05'),(297,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-07 04:39:21'),(298,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 04:38:40'),(299,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 23:47:05'),(300,4,'delete_experiment','experiment',48,'删除实验 25IRD-GH38-251206DG-RIF01','127.0.0.1',NULL,'2025-12-08 23:49:27'),(301,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-09 16:24:19'),(302,4,'save_draft','experiment',49,'保存草稿 55NRD-THK55-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:26:11'),(303,4,'update_draft','experiment',49,'更新草稿 55NRD-THK55-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:26:53'),(304,4,'upload_file','file',90,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-09 16:28:48'),(305,4,'upload_file','file',91,'上传文件: DJI_0499.JPG','127.0.0.1',NULL,'2025-12-09 16:29:00'),(306,4,'update_draft','experiment',49,'更新草稿 55NRD-THK55-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:29:02'),(307,4,'upload_file','file',92,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-12-09 16:30:03'),(308,4,'update_draft','experiment',49,'更新草稿 55NRD-THK55-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:30:06'),(309,4,'save_draft','experiment',50,'保存草稿 150NMP-GP150-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:35:35'),(310,4,'update_draft','experiment',50,'更新草稿 150NMP-GP150-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:38:19'),(311,4,'update_draft','experiment',50,'更新草稿 150NMP-GP150-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:42:50'),(312,4,'update_draft','experiment',50,'更新草稿 150NMP-GP150-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:43:10'),(313,4,'submit_experiment','experiment',50,'提交实验 150NMP-GP150-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:47:13'),(314,4,'save_draft','experiment',51,'保存草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:51:15'),(315,4,'update_draft','experiment',51,'更新草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:52:41'),(316,4,'update_draft','experiment',51,'更新草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:53:32'),(317,4,'update_draft','experiment',51,'更新草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:54:05'),(318,4,'update_draft','experiment',51,'更新草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:55:53'),(319,4,'update_draft','experiment',51,'更新草稿 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 16:56:24'),(320,4,'submit_experiment','experiment',51,'提交实验 150NRD-THK150-251204DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:05:49'),(321,4,'update_draft','experiment',49,'更新草稿 68NRD-LV68-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:12:44'),(322,4,'update_draft','experiment',49,'更新草稿 68NRD-LV68-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:18:20'),(323,4,'submit_experiment','experiment',49,'提交实验 68NRD-LV68-251210DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:19:01'),(324,4,'save_draft','experiment',52,'保存草稿 100NRD-GH100-251201DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:20:52'),(325,4,'submit_experiment','experiment',52,'提交实验 100NRD-GH100-251201DG-RIR01','127.0.0.1',NULL,'2025-12-09 17:43:54'),(326,4,'save_draft','experiment',53,'保存草稿 55DRD-THS55-251210DG-RIR03','127.0.0.1',NULL,'2025-12-09 17:48:41'),(327,4,'update_draft','experiment',53,'更新草稿 55DRD-THS55-251210DG-RIR02','127.0.0.1',NULL,'2025-12-09 20:58:47'),(328,4,'submit_experiment','experiment',54,'提交实验 55DRD-THS55-251210DG-RIR03','127.0.0.1',NULL,'2025-12-09 21:11:15'),(329,4,'submit_experiment','experiment',55,'提交实验 90DRD-GP90-251119XT-RIR05','127.0.0.1',NULL,'2025-12-09 21:19:20'),(330,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-11 04:18:22'),(331,1,'upload_file','file',93,'上传文件: DJI_0489.JPG','127.0.0.1',NULL,'2025-12-11 04:19:06'),(332,1,'save_draft','experiment',56,'保存草稿 25IRD-GH38-251211DG-RIF01','127.0.0.1',NULL,'2025-12-11 04:20:24'),(333,1,'upload_file','file',94,'上传文件: DJI_0486.JPG','127.0.0.1',NULL,'2025-12-11 04:20:37'),(334,1,'update_draft','experiment',56,'更新草稿 25IRD-GH38-251211DG-RIF01','127.0.0.1',NULL,'2025-12-11 04:20:39'),(335,4,'login_success',NULL,NULL,'用户 engineer 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-11 04:21:28'),(336,4,'save_draft','experiment',57,'保存草稿 25IRD-TH538-251211DX-RIF01','127.0.0.1',NULL,'2025-12-11 04:21:52'),(337,4,'upload_file','file',95,'上传文件: DJI_0506.JPG','127.0.0.1',NULL,'2025-12-11 04:21:59'),(338,4,'update_draft','experiment',57,'更新草稿 25IRD-TH538-251211DX-RIF01','127.0.0.1',NULL,'2025-12-11 04:22:04'),(339,4,'upload_file','file',96,'上传文件: DJI_0508.JPG','127.0.0.1',NULL,'2025-12-11 04:31:53'),(340,4,'update_draft','experiment',57,'更新草稿 25IRD-TH538-251211DX-RIF01','127.0.0.1',NULL,'2025-12-11 04:31:54'),(341,4,'upload_file','file',97,'上传文件: 简历.docx','127.0.0.1',NULL,'2025-12-11 04:31:59'),(342,4,'update_draft','experiment',57,'更新草稿 25IRD-TH538-251211DX-RIF01','127.0.0.1',NULL,'2025-12-11 04:32:01'),(343,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-12 03:51:11'),(344,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-12 04:41:41'),(345,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 05:25:14'),(346,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 05:25:36'),(347,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 20:33:51'),(348,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 20:34:41'),(349,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 21:46:21'),(350,7,'login_success',NULL,NULL,'用户 XGP 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 21:47:49'),(351,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-13 21:48:09'),(352,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-16 05:37:43'),(353,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-16 05:44:39'),(354,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-16 05:46:07'),(355,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-16 05:52:43'),(356,1,'backup_error',NULL,NULL,'备份失败 (graphite_backup_20251216_215243.sql): No module named \'config\'','system',NULL,'2025-12-16 05:52:43'),(357,1,'login_success',NULL,NULL,'用户 admin 登录成功','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.19041.6456','2025-12-16 06:18:11');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鐢ㄦ埛琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2b$12$PduedbgBhaGHueQIr6DcpuB2QsZkjlXDr5hxZUKVay/Gphpedvwne','admin','系统管理员','admin@example.com',1,'2025-09-21 12:06:49','2025-12-16 06:18:10','2025-12-16 06:18:10'),(4,'engineer','$2b$12$HqnDExz3sSLcdZYDjzQcYe1XZ23eSKLsHevMz7XvfIYsFzZXsdnn2','engineer','工程师','engineer@example.com',1,'2025-11-21 12:38:43','2025-12-11 04:21:28','2025-12-11 04:21:28'),(5,'user','$2b$12$.7vLygHOilBvt9Nh7ELRuO2yvPzWxOU9Ay8NV0cxY0M0sLDLlC9ZK','user','普通用户','user@example.com',1,'2025-11-21 12:38:43','2025-12-06 20:10:26','2025-12-06 20:10:26'),(6,'tzm','scrypt:32768:8:1$VYhiYJhoM8UdDyVQ$d156f18097e8121f23815bd15288737db817b77e60c48f8a3737990fef0255fd6ed9a228fb699743e68143014116853ba570626b443de2ab19f1b795a2f8c1d6','engineer','TZM','',1,'2025-12-13 18:08:30','2025-12-13 22:46:22',NULL),(7,'XGP','$2b$12$hdNNXRP6FnW0V1qdQ1YiVu9sHaY2LZmm2R8OIPNAEA/ilcNqgCd5u','engineer','','',0,'2025-12-13 21:47:19','2025-12-13 22:45:26','2025-12-13 21:47:49');
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

-- Dump completed on 2025-12-16 22:18:11
