CREATE TABLE IF NOT EXISTS reports (
 	`reporter_id` INT(11) PRIMARY KEY,
 	`reason` VARCHAR(8000),
 	`timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`status` VARCHAR(50)
 );