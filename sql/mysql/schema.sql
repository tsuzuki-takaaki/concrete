-- Do not add foreign key here
USE `concrete`;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`email` VARCHAR(255) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`tittle` VARCHAR(255) NOT NULL,
	`content` TEXT NOT NULL,
	`user_id` INT NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `idx_userid` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;
