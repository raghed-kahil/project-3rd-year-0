USE `project`;

INSERT INTO `customers` (`first_name`,`last_name`, `phone_number`,`national_id`) VALUES
    ('Ahmad','','',0),
    ('Mohammad','','',0),
    ('Fadi','','',0),
    ('Mazen','','',0),
    ('Ali','','',0),
    ('Samer','','',0);

INSERT INTO h_room_types (`name`,`default_price`) VALUES
    ('vip',10000),
    ('SUPER VIP',100000);

INSERT INTO h_rooms (`floor`,`type_id`,`capacity`) VALUES
	(1,1,5),
    (1,2,10),
    (1,1,3);

INSERT INTO h_bookings () VALUES (),();

INSERT INTO h_booking_rooms (`room_id`,`booking_id`,`price_per_day`) VALUES
	(1,1,NULL),
    (2,1,50000),
    (3,2,15000);

INSERT INTO h_booked_room_customers (`customer_id`,`booking_room_id`) VALUES
	(1,1),(2,1),
    (3,2),(4,2),
    (5,3),(6,3);

INSERT INTO r_menu_categories (`name`) VALUES 
	('drinks'),('junk_food'),('fish');

INSERT INTO r_menu (`name`,`category_id`,`price`) VALUES 
	('salamon',3,30000),
    ('tuna',3,20000),
    ('tea',1,10000),
    ('coffee',1,15000),
    ('fries',2,20000),
    ('beef_bugref',2,50000);

INSERT INTO r_suits (name,price_per_table,max_tables_capacity) VALUES 
	('outside',1000,100),
    ('vip',10000,30),
    ('balcony',5000,50);

INSERT INTO r_bookings (customer_id, tables_count, suit_id) VALUES 
	(1,2,2),
    (5,1,1);

INSERT INTO r_booking_orders (booking_id,menu_item_id,amount) VALUES
	(1,4,4),
    (1,5,6),
    (1,6,1),
    (1,1,2),
    (1,2,1),
    (1,3,4),
    (2,2,2),
    (2,3,2);