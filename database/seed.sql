USE lost_found_intelligence;

INSERT INTO user (name,email,password_hash,phone,role) VALUES
('Aarav Sharma','aarav@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543201','ADMIN'),
('Divya Rao','divya@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543202','USER'),
('Rohan Nair','rohan@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543203','USER'),
('Ananya Singh','ananya@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543204','USER'),
('Meera Pai','meera@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543205','USER'),
('Shreya R D','shreya@pes.edu','$2b$10$CaRNDuQhTkQL6ZRww932iu3otpHBtfjzl1COvr5ELdC441Vwi5mGu','9876543206','USER');

INSERT INTO category (name,description) VALUES
('Electronics','Phones, laptops, chargers'),('Bags','Backpacks and handbags'),('Wallets','Wallets and card holders'),
('Documents','Certificates and papers'),('Keys','Vehicle and room keys'),('Clothing','Jackets and uniforms'),
('Accessories','Watches and jewellery'),('Books','Textbooks and notes'),('Stationery','Pens and notebooks'),
('Sports','Sports equipment'),('Bottles','Water bottles and flasks'),('Other','Items that fit no category'),
('ID Cards','College identity cards and holders');

INSERT INTO location (name,building,floor) VALUES
('Main Cafeteria','Central Block','Ground Floor'),('Central Library','Library Block','1st Floor'),
('Computer Lab 1','Academic Block A','2nd Floor'),('Academic Block A','Academic Block A','Ground Floor'),
('Parking Area','Campus','Ground Floor'),('Sports Ground','Campus','Ground Floor'),
('Block D Corridor','Block D','1st Floor'),('Student Center','Student Center','Ground Floor'),
('Innovation Lab','Technology Block','2nd Floor');

INSERT INTO lost_item (user_id,category_id,location_id,title,description,lost_date_time,status) VALUES
(2,2,1,'Black Backpack','Black backpack with notebooks and a blue water bottle','2026-10-01 09:15:00','ACTIVE'),
(3,1,2,'Samsung Galaxy Phone','Samsung phone with cracked screen protector','2026-10-02 13:40:00','ACTIVE'),
(4,3,3,'Brown Leather Wallet','Brown leather wallet with student ID','2026-10-02 16:05:00','ACTIVE'),
(1,8,4,'Database Textbook','Database Systems textbook with highlights','2026-10-03 11:20:00','ACTIVE'),
(5,5,5,'Motorcycle Keys','Two motorcycle keys attached to a small blue keychain','2026-10-03 17:45:00','ACTIVE'),
(2,7,6,'Black Wrist Watch','Black analog watch with scratched glass','2026-10-03 08:30:00','ACTIVE'),
(3,6,7,'Blue Denim Jacket','Blue denim jacket with a small white patch','2026-10-04 10:00:00','ACTIVE'),
(4,9,8,'Blue Notebook','Blue notebook with sketches','2026-10-04 12:10:00','ACTIVE'),
(5,11,2,'Steel Water Bottle','Silver steel bottle with a dent','2026-10-04 14:25:00','ACTIVE'),
(6,13,9,'College ID Holder','Blue ID holder containing college identity card','2026-10-04 10:30:00','ACTIVE');

INSERT INTO found_item (user_id,category_id,location_id,title,description,found_date_time,status) VALUES
(1,2,1,'Black Bag','Black bag with notebooks and a blue bottle inside','2026-10-01 11:00:00','AVAILABLE'),
(2,1,2,'Samsung Phone','Samsung phone with cracked screen protector found near canteen','2026-10-02 15:00:00','AVAILABLE'),
(3,3,3,'Leather Wallet','Brown leather wallet with student ID found','2026-10-02 17:30:00','AVAILABLE'),
(4,8,4,'DBMS Textbook','Database Systems textbook with highlights','2026-10-03 12:00:00','AVAILABLE'),
(5,5,5,'Bike Keys','Two motorcycle keys with a blue keychain','2026-10-03 18:00:00','AVAILABLE'),
(1,13,9,'Blue ID Holder','Blue ID holder found near the Innovation Lab','2026-10-04 12:00:00','AVAILABLE'),
(2,7,6,'Wrist Watch','Black analog watch with scratched glass','2026-10-03 09:30:00','AVAILABLE'),
(3,9,8,'Blue Notebook','Blue notebook with sketches','2026-10-04 13:00:00','AVAILABLE');

INSERT INTO item_match (lost_item_id,found_item_id,similarity_score,match_reason,status) VALUES
(1,1,0.7800,'Same category and location; similar description.','PENDING'),
(2,2,0.9200,'High-confidence match on title, category, location and description.','CONFIRMED'),
(3,3,0.8800,'Same category and location; matching description.','PENDING'),
(4,4,0.9500,'High-confidence match on title, category, location and description.','CONFIRMED'),
(5,5,0.8600,'Same category and location; similar description.','PENDING'),
(6,7,0.9300,'High-confidence match on title, category, location and description.','CONFIRMED'),
(8,8,0.9700,'High-confidence match on title, category, location and description.','CONFIRMED'),
(10,6,0.9700,'High-confidence match based on title, category, location and item description.','CONFIRMED');

INSERT INTO claim (user_id,lost_item_id,found_item_id,claim_description,status) VALUES
(6,10,6,'This is my blue college ID holder containing my college identity card.','PENDING');

INSERT INTO notification (user_id,related_type,related_id,message,status) VALUES
(6,'MATCH',10,'A potential match has been found for your lost College ID Holder.','UNREAD'),
(2,'MATCH',1,'A potential match has been found for your lost Black Backpack.','UNREAD'),
(3,'MATCH',2,'A potential match has been found for your lost Samsung Galaxy Phone.','READ');

INSERT INTO item_embedding (item_type,item_id,embedding_reference,model_name) VALUES
('LOST',10,'embedding/lost_item_10','Sentence-BERT');

INSERT INTO item_image (lost_item_id,found_item_id,image_url,image_type) VALUES
(10,NULL,'https://example.com/images/college_id_holder_10.jpg','LOST');
