-- -----------------------------------------------------
-- Schema WSO2DM_APPM_DB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table APPM_PLATFORM
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_PLATFORM (
ID INT NOT NULL AUTO_INCREMENT UNIQUE,
IDENTIFIER VARCHAR (100) NOT NULL,
TENANT_ID INT NOT NULL ,
NAME VARCHAR (255),
FILE_BASED BOOLEAN,
DESCRIPTION LONGVARCHAR,
IS_SHARED BOOLEAN,
IS_DEFAULT_TENANT_MAPPING BOOLEAN,
ICON_NAME VARCHAR (100),
PRIMARY KEY (IDENTIFIER, TENANT_ID)
);

CREATE TABLE IF NOT EXISTS APPM_PLATFORM_PROPERTIES (
ID INT NOT NULL AUTO_INCREMENT,
PLATFORM_ID INT NOT NULL,
PROP_NAME VARCHAR (100) NOT NULL,
OPTIONAL BOOLEAN,
DEFAUL_VALUE VARCHAR (255),
FOREIGN KEY(PLATFORM_ID) REFERENCES APPM_PLATFORM(ID) ON DELETE CASCADE,
PRIMARY KEY (ID, PLATFORM_ID, PROP_NAME)
);

CREATE TABLE IF NOT EXISTS APPM_PLATFORM_TENANT_MAPPING (
ID INT NOT NULL AUTO_INCREMENT,
TENANT_ID INT NOT NULL ,
PLATFORM_ID INT NOT NULL,
FOREIGN KEY(PLATFORM_ID) REFERENCES APPM_PLATFORM(ID) ON DELETE CASCADE,
PRIMARY KEY (ID, TENANT_ID, PLATFORM_ID)
);

CREATE INDEX IF NOT EXISTS FK_PLATFROM_TENANT_MAPPING_PLATFORM ON APPM_PLATFORM_TENANT_MAPPING(PLATFORM_ID ASC);

-- -----------------------------------------------------
-- Table APPM_APPLICATION_CATEGORY
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_APPLICATION_CATEGORY (
  ID INT NOT NULL AUTO_INCREMENT,
  NAME VARCHAR(100) NOT NULL,
  DESCRIPTION TEXT NULL,
  PUBLISHED TINYINT NULL,
  PRIMARY KEY (ID));

INSERT INTO APPM_APPLICATION_CATEGORY (NAME, DESCRIPTION, PUBLISHED) VALUES ('Enterprise', 'Enterprise level
applications which the artifacts need to be provided', 1);
INSERT INTO APPM_APPLICATION_CATEGORY (NAME, DESCRIPTION, PUBLISHED) VALUES ('Public', 'Public category in which the
application need to be downloaded from the public application store', 1);

-- -----------------------------------------------------
-- Table `APPM_LIFECYCLE_STATE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_LIFECYCLE_STATE (
  ID INT NOT NULL AUTO_INCREMENT UNIQUE,
  NAME VARCHAR(100) NOT NULL,
  IDENTIFIER VARCHAR(100) NOT NULL,
  DESCRIPTION TEXT NULL,
  PRIMARY KEY (ID),
  UNIQUE INDEX APPM_LIFECYCLE_STATE_IDENTIFIER_UNIQUE (IDENTIFIER ASC));

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION) VALUES ('CREATED', 'CREATED', 'Application creation
initial state');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('IN REVIEW', 'IN REVIEW', 'Application is in in-review state');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('APPROVED', 'APPROVED', 'State in which Application is approved after reviewing.');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('REJECTED', 'REJECTED', 'State in which Application is rejected after reviewing.');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('PUBLISHED', 'PUBLISHED', 'State in which Application is in published state.');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('UNPUBLISHED', 'UNPUBLISHED', 'State in which Application is in un published state.');
INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('RETIRED', 'RETIRED', 'Retiring an application to indicate end of life state,');


CREATE TABLE IF NOT EXISTS APPM_LIFECYCLE_STATE_TRANSITION
(
  ID INT NOT NULL AUTO_INCREMENT UNIQUE,
  INITIAL_STATE INT,
  NEXT_STATE INT,
  PERMISSION VARCHAR(1024),
  DESCRIPTION VARCHAR(2048),
  PRIMARY KEY (INITIAL_STATE, NEXT_STATE),
  FOREIGN KEY (INITIAL_STATE) REFERENCES APPM_LIFECYCLE_STATE(ID) ON DELETE CASCADE,
  FOREIGN KEY (NEXT_STATE) REFERENCES APPM_LIFECYCLE_STATE(ID) ON DELETE CASCADE
);

INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (1, 2, null, 'Submit for review');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 1, null, 'Revoke from review');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 3, '/permission/admin/manage/device-mgt/application/review', 'APPROVE');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 4, '/permission/admin/manage/device-mgt/application/review', 'REJECT');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (3, 4, '/permission/admin/manage/device-mgt/application/review', 'REJECT');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (3, 5, null, 'PUBLISH');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (5, 6, null, 'UN PUBLISH');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 5, null, 'PUBLISH');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (4, 1, null, 'Return to CREATE STATE');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 1, null, 'Return to CREATE STATE');
INSERT INTO APPM_LIFECYCLE_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 7, null, 'Retire');

-- -----------------------------------------------------
-- Table APPM_APPLICATION
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `APPM_APPLICATION` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `UUID` VARCHAR(100) NOT NULL,
  `IDENTIFIER` VARCHAR(255) NULL,
  `NAME` VARCHAR(100) NOT NULL,
  `SHORT_DESCRIPTION` VARCHAR(255) NULL,
  `DESCRIPTION` TEXT NULL,
  `SCREEN_SHOT_COUNT` INT DEFAULT 0,
  `VIDEO_NAME` VARCHAR(100) NULL,
  `CREATED_BY` VARCHAR(255) NULL,
  `CREATED_AT` DATETIME NOT NULL,
  `MODIFIED_AT` DATETIME NULL,
  `IS_FREE` TINYINT(1) NULL,
  `PAYMENT_CURRENCY` VARCHAR(45) NULL,
  `PAYMENT_PRICE` DECIMAL(10,2) NULL,
  `APPLICATION_CATEGORY_ID` INT NOT NULL,
  `LIFECYCLE_STATE_ID` INT NOT NULL,
  `LIFECYCLE_STATE_MODIFIED_BY` VARCHAR(255) NULL,
  `LIFECYCLE_STATE_MODIFIED_AT` DATETIME NULL,
  `TENANT_ID` INT NOT NULL,
  `PLATFORM_ID` INT NOT NULL,
  PRIMARY KEY (`ID`, `APPLICATION_CATEGORY_ID`, `LIFECYCLE_STATE_ID`, `PLATFORM_ID`),
  UNIQUE INDEX `UUID_UNIQUE` (`UUID` ASC),
  FOREIGN KEY (`APPLICATION_CATEGORY_ID`)
  REFERENCES `APPM_APPLICATION_CATEGORY` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_APPM_APPLICATION_APPM_LIFECYCLE_STATE1`
  FOREIGN KEY (`LIFECYCLE_STATE_ID`)
  REFERENCES `APPM_LIFECYCLE_STATE` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_APPM_APPLICATION_APPM_PLATFORM1`
  FOREIGN KEY (`PLATFORM_ID`)
  REFERENCES `APPM_PLATFORM` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX IF NOT EXISTS FK_APPLICATION_APPLICATION_CATEGORY ON APPM_APPLICATION(APPLICATION_CATEGORY_ID ASC);

-- -----------------------------------------------------
-- Table APPM_APPLICATION_PROPERTY
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_APPLICATION_PROPERTY (
  PROP_KEY VARCHAR(255) NOT NULL,
  PROP_VAL TEXT NULL,
  APPLICATION_ID INT NOT NULL,
  PRIMARY KEY (PROP_KEY, APPLICATION_ID),
  CONSTRAINT FK_APPLICATION_PROPERTY_APPLICATION
    FOREIGN KEY (APPLICATION_ID)
    REFERENCES APPM_APPLICATION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPLICATION_PROPERTY_APPLICATION ON APPM_APPLICATION_PROPERTY(APPLICATION_ID ASC);

-- -----------------------------------------------------
-- Table APPM_APPLICATION_RELEASE
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_APPLICATION_RELEASE (
  ID INT NOT NULL AUTO_INCREMENT,
  VERSION_NAME VARCHAR(100) NOT NULL,
  RESOURCE TEXT NULL,
  RELEASE_CHANNEL VARCHAR(50) DEFAULT 'ALPHA',
  RELEASE_DETAILS TEXT NULL,
  CREATED_AT DATETIME NOT NULL,
  APPM_APPLICATION_ID INT NOT NULL,
  IS_DEFAULT TINYINT NULL,
  PRIMARY KEY (APPM_APPLICATION_ID, VERSION_NAME),
  CONSTRAINT FK_APPLICATION_VERSION_APPLICATION
    FOREIGN KEY (APPM_APPLICATION_ID)
    REFERENCES APPM_APPLICATION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPLICATION_VERSION_APPLICATION ON APPM_APPLICATION_RELEASE(APPM_APPLICATION_ID ASC);

-- -----------------------------------------------------
-- Table APPM_RELEASE_PROPERTY
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_RELEASE_PROPERTY (
  PROP_KEY VARCHAR(255) NOT NULL,
  PROP_VALUE TEXT NULL,
  APPLICATION_RELEASE_ID INT NOT NULL,
  PRIMARY KEY (PROP_KEY, APPLICATION_RELEASE_ID),
  CONSTRAINT FK_RELEASE_PROPERTY_APPLICATION_RELEASE
    FOREIGN KEY (APPLICATION_RELEASE_ID)
    REFERENCES APPM_APPLICATION_RELEASE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_RELEASE_PROPERTY_APPLICATION_RELEASE ON APPM_RELEASE_PROPERTY(APPLICATION_RELEASE_ID ASC);

-- -----------------------------------------------------
-- Table APPM_RESOURCE_TYPE
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_RESOURCE_TYPE (
  ID INT NOT NULL AUTO_INCREMENT,
  NAME VARCHAR(45) NULL,
  DESCRIPTION TEXT NULL,
  PRIMARY KEY (ID));

-- -----------------------------------------------------
-- Table APPM_SUBSCRIPTION
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_SUBSCRIPTION (
  ID INT NOT NULL AUTO_INCREMENT,
  VALUE VARCHAR(255) NOT NULL,
  CREATED_AT DATETIME NOT NULL,
  RESOURCE_TYPE_ID INT NOT NULL,
  APPLICATION_ID INT NOT NULL,
  APPLICATION_RELEASE_ID INT NULL,
  PRIMARY KEY (ID, APPLICATION_ID, RESOURCE_TYPE_ID),
  CONSTRAINT fk_APPM_APPLICATION_SUBSCRIPTION_APPM_RESOURCE_TYPE1
    FOREIGN KEY (RESOURCE_TYPE_ID)
    REFERENCES APPM_RESOURCE_TYPE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_APPM_APPLICATION_SUBSCRIPTION_APPM_APPLICATION1
    FOREIGN KEY (APPLICATION_ID)
    REFERENCES APPM_APPLICATION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_APPM_APPLICATION_SUBSCRIPTION_APPM_APPLICATION_RELEASE1
    FOREIGN KEY (APPLICATION_RELEASE_ID)
    REFERENCES APPM_APPLICATION_RELEASE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPLICATION_SUBSCRIPTION_RESOURCE_TYPE ON APPM_SUBSCRIPTION(RESOURCE_TYPE_ID ASC);
CREATE INDEX FK_APPLICATION_SUBSCRIPTION_APPLICATION ON APPM_SUBSCRIPTION(APPLICATION_ID ASC);
CREATE INDEX FK_APPLICATION_SUBSCRIPTION_APPLICATION_RELEASE ON APPM_SUBSCRIPTION(APPLICATION_RELEASE_ID ASC);

-- -----------------------------------------------------
-- Table APPM_COMMENT
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_COMMENT (
  ID INT NOT NULL AUTO_INCREMENT,
  APPLICATION_RELEASE_ID INT NOT NULL,
  COMMENT_SUBJECT VARCHAR(255) NULL,
  COMMENT_BODY TEXT NULL,
  RATING INT NULL,
  PARENT_ID INT NULL,
  CREATED_AT DATETIME NOT NULL,
  CREATED_BY VARCHAR(45) NULL,
  MODIFIED_AT DATETIME NULL,
  PUBLISHED TINYINT NULL,
  APPROVED TINYINT NULL,
  PRIMARY KEY (ID, APPLICATION_RELEASE_ID),
  CONSTRAINT FK_APPLICATION_COMMENTS_APPLICATION_RELEASE
    FOREIGN KEY (APPLICATION_RELEASE_ID)
    REFERENCES APPM_APPLICATION_RELEASE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPLICATION_COMMENTS_APPLICATION_RELEASE ON APPM_COMMENT(APPLICATION_RELEASE_ID ASC);

-- -----------------------------------------------------
-- Table APPM_PLATFORM_TAG
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_PLATFORM_TAG (
  name VARCHAR(100) NOT NULL,
  PLATFORM_ID INT NOT NULL,
  PRIMARY KEY (PLATFORM_ID, name),
  CONSTRAINT fk_APPM_SUPPORTED_PLATFORM_TAGS_APPM_SUPPORTED_PLATFORM1
    FOREIGN KEY (PLATFORM_ID)
    REFERENCES APPM_PLATFORM (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_PLATFORM_TAGS_PLATFORM ON APPM_PLATFORM_TAG(PLATFORM_ID ASC);

-- -----------------------------------------------------
-- Table APPM_APPLICATION_TAG
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_APPLICATION_TAG (
  name VARCHAR(45) NOT NULL,
  APPLICATION_ID INT NOT NULL,
  PRIMARY KEY (APPLICATION_ID, name),
  CONSTRAINT fk_APPM_APPLICATION_TAG_APPM_APPLICATION1
    FOREIGN KEY (APPLICATION_ID)
    REFERENCES APPM_APPLICATION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPLICATION_TAG_APPLICATION ON APPM_APPLICATION_TAG(APPLICATION_ID ASC);

-- -----------------------------------------------------
-- Table APPM_VISIBILITY
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_VISIBILITY (
  ID INT NOT NULL AUTO_INCREMENT,
  VALUE VARCHAR(255) NOT NULL,
  RESOURCE_TYPE_ID INT NOT NULL,
  APPLICATION_RELEASE_ID INT NULL,
  APPLICATION_ID INT NULL,
  PRIMARY KEY (ID, RESOURCE_TYPE_ID),
  CONSTRAINT fk_APPM_VISIBILITY_APPM_RESOURCE_TYPE1
    FOREIGN KEY (RESOURCE_TYPE_ID)
    REFERENCES APPM_RESOURCE_TYPE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_APPM_VISIBILITY_APPM_APPLICATION_RELEASE1
    FOREIGN KEY (APPLICATION_RELEASE_ID)
    REFERENCES APPM_APPLICATION_RELEASE (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_APPM_VISIBILITY_APPM_APPLICATION1
    FOREIGN KEY (APPLICATION_ID)
    REFERENCES APPM_APPLICATION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_APPM_VISIBILITY_RESOURCE_TYPE ON APPM_VISIBILITY(RESOURCE_TYPE_ID ASC);
CREATE INDEX FK_VISIBILITY_APPLICATION_RELEASE ON APPM_VISIBILITY(APPLICATION_RELEASE_ID ASC);
CREATE INDEX FK_VISIBILITY_APPLICATION ON APPM_VISIBILITY(APPLICATION_ID ASC);

-- -----------------------------------------------------
-- Table APPM_SUBSCRIPTION_PROPERTIES
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS APPM_SUBSCRIPTION_PROPERTIES (
  PROP_KEY VARCHAR(500) NOT NULL,
  PROP_VALUE VARCHAR(500) NULL,
  APPM_SUBSCRIPTION_ID INT NOT NULL,
  PRIMARY KEY (PROP_KEY, APPM_SUBSCRIPTION_ID),
  CONSTRAINT fk_APPM_SUBSCRIPTION_PROPERTIES_APPM_SUBSCRIPTION1
    FOREIGN KEY (APPM_SUBSCRIPTION_ID)
    REFERENCES APPM_SUBSCRIPTION (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX FK_SUBSCRIPTION_PROPERTIES_SUBSCRIPTION ON APPM_SUBSCRIPTION_PROPERTIES(APPM_SUBSCRIPTION_ID ASC);