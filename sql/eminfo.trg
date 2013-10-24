
-- {{{ trigger_newer_postlog
DELIMITER //
DROP TRIGGER IF EXISTS trigger_newer_postlog //
CREATE TRIGGER trigger_newer_postlog AFTER INSERT
ON postlog FOR EACH ROW
BEGIN
DECLARE $hostnum INT(10);
	SELECT COUNT(id) INTO $hostnum FROM hosts WHERE id=NEW.id;
	IF $hostnum <= 0 THEN
		INSERT INTO hosts (id,name) VALUES (NEW.id,New.name);	
	END IF;
	INSERT INTO plugins (id,plugin) VALUES (NEW.id,NEW.plugin);
END;

-- {{{ trigger_archive_postlog
DROP TRIGGER IF EXISTS trigger_archive_postlog //
CREATE TRIGGER trigger_archive_postlog AFTER UPDATE
ON postlog FOR EACH ROW
BEGIN
	INSERT INTO postlog_archive (id,name,time,plugin,content)
	VALUES (OLD.id,OLD.name,OLD.time,OLD.plugin,OLD.content);
END;

-- {{{ trigger_archive_heartbeat
DROP TRIGGER IF EXISTS trigger_archive_heartbeat //
CREATE TRIGGER trigger_archive_heartbeat AFTER UPDATE
ON heartbeat FOR EACH ROW 
BEGIN
        INSERT INTO heartbeat_archive (id,time,content)
        VALUES (OLD.id,OLD.time,OLD.content);
END;
