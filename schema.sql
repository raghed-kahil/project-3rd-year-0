DROP DATABASE IF EXISTS `project`;
CREATE DATABASE `project` COLLATE=utf8_unicode_ci;

USE `project`;


CREATE TABLE `customers`(
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `phone_number` VARCHAR(255) NOT NULL,
    `national_id` VARCHAR(255) NULL 
);

-- HOTEL --

CREATE TABLE `h_room_types` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `default_price` DECIMAL(8,2) UNSIGNED  NOT NULL
);

CREATE TABLE `h_rooms` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `floor` TINYINT NOT NULL,
    `type_id` INT UNSIGNED NOT NULL,
    `capacity` TINYINT UNSIGNED,
    `is_available` BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY `fk_HR_type_id` (`type_id`) REFERENCES `h_room_types`(`id`)
);

CREATE TABLE `h_bookings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE `h_booking_rooms` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT UNSIGNED NOT NULL,
    `booking_id` INT UNSIGNED NOT NULL,
    `enter_date` DATE NOT NULL DEFAULT CURRENT_DATE,
    `leave_date` DATE NULL,
    `price_per_day` DECIMAL(8,2) NULL,
    FOREIGN KEY `fk_HBR_room_id` (`room_id`) REFERENCES `h_rooms`(`id`),
    FOREIGN KEY `fk_HBR_booking_id` (`booking_id`) REFERENCES `h_bookings`(`id`)
);

DELIMITER $$
CREATE TRIGGER `tr_HBR_bi` BEFORE INSERT ON `h_booking_rooms` FOR EACH ROW
    IF NEW.price_per_day IS NULL THEN
        SET NEW.price_per_day = 
        (SELECT HRT.default_price FROM h_rooms HR, h_room_types HRT 
        WHERE HR.type_id=HRT.id AND HR.id=NEW.room_id);
    END IF$$
DELIMITER ;

CREATE TABLE `h_booked_room_customers` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT UNSIGNED NOT NULL,
    `booking_room_id` INT UNSIGNED NOT NULL,
    FOREIGN KEY `fk_HBRC_customer_id` (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY `fk_HBRC_booking_room_id` (`booking_room_id`) REFERENCES `h_booking_rooms`(`id`)
);

CREATE VIEW `h_bills` AS 
SELECT payers.booking_id,payers.customer_id,prices.price FROM
	(SELECT booking_id,SUM(price_per_day*(leave_date-enter_date)) price 
	FROM h_booking_rooms GROUP BY (booking_id)) prices,
    
    (SELECT HBR.booking_id, MIN(HBRC.customer_id) customer_id FROM
     h_booked_room_customers HBRC,h_booking_rooms HBR WHERE
     HBR.id=HBRC.booking_room_id GROUP BY (HBR.booking_id)) payers
     
     WHERE payers.booking_id=prices.booking_id;

-- RESTAURANT --

CREATE TABLE `r_suits` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `price_per_table` DECIMAL(8,2) UNSIGNED NULL,
    `max_tables_capacity` SMALLINT UNSIGNED NOT NULL
);


CREATE TABLE `r_menu_categories` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `r_menu` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `price` DECIMAL(8,2) UNSIGNED NOT NULL,
    `category_id` INT UNSIGNED NOT NULL,
    FOREIGN KEY `fk_RM_category_id` (`category_id`) REFERENCES `r_menu_categories`(`id`)
);

CREATE TABLE `r_taxes` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `min_total` DECIMAL(10,2) UNSIGNED,
    `tax_rate` FLOAT UNSIGNED
);

CREATE TABLE `r_bookings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT UNSIGNED NOT NULL,
    `tables_count` SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `suit_id` INT UNSIGNED NOT NULL,
    `price_per_table` DECIMAL(8,2) UNSIGNED NULL,
    FOREIGN KEY `fk_RB_customer_id` (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY `fk_RB_suit_id` (`suit_id`) REFERENCES `r_suits`(`id`)
);


DELIMITER $$
CREATE TRIGGER `tr_RB_bi` BEFORE INSERT ON `r_bookings` FOR EACH ROW
    IF NEW.price_per_table IS NULL THEN
        SET NEW.price_per_table = (SELECT `price_per_table` FROM `r_suits` WHERE `id`=NEW.`suit_id`);
    END IF$$
DELIMITER ;

CREATE TABLE `r_booking_orders` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `booking_id` INT UNSIGNED NOT NULL,
    `menu_item_id` INT UNSIGNED NOT NULL,
    `price` DECIMAL(8,2) UNSIGNED NULL,
    `amount` INT UNSIGNED NOT NULL DEFAULT 1,
    FOREIGN KEY `fk_RBO_booking_id` (`booking_id`) REFERENCES `r_bookings`(`id`),
    FOREIGN KEY `fk_RBO_menu_item_id` (`menu_item_id`) REFERENCES `r_menu`(`id`)
);

DELIMITER $$
CREATE TRIGGER `tr_RBO_bi` BEFORE INSERT ON `r_booking_orders` FOR EACH ROW
    IF NEW.price IS NULL THEN
        SET NEW.price = (SELECT `price` FROM `r_menu` WHERE `id`=NEW.`menu_item_id`);
    END IF$$
DELIMITER ;

CREATE VIEW r_bills_totals AS
    SELECT RB.id booking_id,c.first_name,SUM(RBO.price*RBO.amount) subtotal FROM r_booking_orders RBO,r_bookings RB,customers C WHERE
	RBO.booking_id=RB.id AND RB.customer_id=C.id GROUP BY RB.id,c.first_name;

-- INTERTAIMENT

CREATE TABLE `i_sections`(
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `i_games` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `i_section_games` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `section_id` INT UNSIGNED NOT NULL,
    `game_id` INT UNSIGNED NOT NULL,
    FOREIGN KEY `fk_ISG_section_id` (`section_id`) REFERENCES `i_sections`(`id`),
    FOREIGN KEY `fk_ISG_game_id` (`game_id`) REFERENCES `i_games`(`id`)
);

CREATE TABLE `i_tickets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `price` DECIMAL(8,2) UNSIGNED,
    `validity_duration` INT UNSIGNED NOT NULL DEFAULT 0
);

CREATE TABLE `i_ticket_games` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` INT UNSIGNED,
    `section_game_id` INT UNSIGNED,
    FOREIGN KEY `fk_ITG_ticket_id` (`ticket_id`) REFERENCES `i_tickets`(`id`),
    FOREIGN KEY `fk_ITG_section_game_id` (`section_game_id`) REFERENCES `i_section_games`(`id`)
);

CREATE TABLE `i_customer_tickets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT UNSIGNED NULL,
    `ticket_id` INT UNSIGNED NOT NULL,
    `price` DECIMAL(8,2) NULL,
    `start_time` DATETIME NULL,
    FOREIGN KEY `fk_ICT_customer_id` (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY `fk_ICT_ticket_id` (`ticket_id`) REFERENCES `i_tickets`(`id`)
);

DELIMITER $$
CREATE TRIGGER `tr_ICT_bi` BEFORE INSERT ON `i_customer_tickets` FOR EACH ROW
IF NEW.price IS NULL THEN
    SET NEW.price = (SELECT `price` FROM `i_tickets` WHERE `id`=NEW.`ticket_id`);
END IF$$
DELIMITER ;

-- ADMINISTRATION 

CREATE TABLE `a_jobs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `a_employees` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `national_id` VARCHAR(255) NOT NULL,
    `section` ENUM('H','R','I') NULL,
    `salary` DECIMAL(8,2) UNSIGNED NULL DEFAULT 0
);

CREATE TABLE `a_employee_jobs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT UNSIGNED,
    `job_id` INT UNSIGNED,
    `start_date` DATE NOT NULL DEFAULT CURRENT_DATE,
    `end_date` DATE NULL,
    FOREIGN KEY `fk_AEJ_employee_id` (`employee_id`) REFERENCES `a_employees`(`id`),
    FOREIGN KEY `fk_AEJ_job_id` (`job_id`) REFERENCES `a_jobs`(`id`)
);

CREATE TABLE `a_vacation_types` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `a_employee_vacations` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT UNSIGNED,
    `type_id` INT UNSIGNED,
    `start_date` DATE NOT NULL DEFAULT CURRENT_DATE,
    `end_date` DATE NULL,
    FOREIGN KEY `fk_AEV_employee_id` (`employee_id`) REFERENCES `a_employees`(`id`),
    FOREIGN KEY `fk_AEV_type_id` (`type_id`) REFERENCES `a_vacation_types`(`id`)
);