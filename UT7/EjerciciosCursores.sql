DELIMITER $$
CREATE TABLE noticias (
	id int primary key auto_increment,
	titulo VARCHAR(200),
	contenido TEXT
)$$

CREATE PROCEDURE cursorEjemplo ()
BEGIN
	DECLARE tmp VARCHAR(200);
	DECLARE lrf bool;
	DECLARE nn int;
	DECLARE cursor2 CURSOR FOR SELECT titulo FROM noticias;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET lrf=1;
    
	SET lrf=0,nn=0;
    
	OPEN cursor2;
	1_cursor: REPEAТ
	FETCH cursor2 INTO tmp;
	set nn=nn+1;
	IF lrf=1 THEN LEAVE 1_cursor;
	END IF;
	UNTIL lrf
	END REРEAT 1_cursor;
	CLOSE cursor2;
	SELECT nn;
END; $$