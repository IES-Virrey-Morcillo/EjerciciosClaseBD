DELIMITER $$
CREATE TABLE noticias (
	id int primary key auto_increment,
	titulo VARCHAR(200),
	contenido TEXT
)$$

DROP PROCEDURE IF EXISTS cursorEjemplo$$
CREATE PROCEDURE cursorEjemplo()
BEGIN
	DECLARE tmp VARCHAR(200);
	DECLARE lrf boolean;
	DECLARE contador int;
    
	DECLARE cursor2 CURSOR FOR SELECT titulo FROM noticias;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET lrf=1;
    
	SET lrf=0,contador=0;
    
	OPEN cursor2;
	l_cursor: REPEAT
		FETCH cursor2 INTO tmp;
		set contador=contador+1;
	UNTIL lrf END REPEAT l_cursor;
	CLOSE cursor2;
	SELECT contador;
END$$

CALL cursorEjemplo()$$

-- Ejercicio 1.
DROP PROCEDURE personasPaisContinente $$
CREATE PROCEDURE personasPaisContinente () 
BEGIN
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
	DECLARE vContinente VARCHAR(20);
    DECLARE vNumPaises, vSumPoblacion BIGINT;
    -- Los cursores deben declararse después de todas las variables.
    DECLARE cursorContinentes CURSOR FOR SELECT DISTINCT Continent FROM Country;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos=TRUE;

    
    OPEN cursorContinentes;
    
    bucle: REPEAT
		FETCH cursorContinentes INTO vContinente;
        if finDatos = 0 THEN
			SELECT COUNT(*), SUM(Population)
			INTO vNumPaises, vSumPoblacion
			FROM Country
			WHERE Continent = vContinente;
			SELECT CONCAT("En el continente ", vContinente,
						  " viven ", vSumPoblacion, " personas en ",
						  vNumPaises, " países diferentes");
		END IF;
    UNTIL finDatos END REPEAT bucle;
    
    CLOSE cursorContinentes;
    
END$$

CALL personasPaisContinente()$$


DROP PROCEDURE IF EXISTS poblacionCapitales $$
CREATE PROCEDURE poblacionCapitales (in continente enum('Asia','Europe','North_America','Africa','Oceania','Antarctica','South_America'))
BEGIN 
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    DECLARE vNombrePais VARCHAR(52);
    DECLARE vCapitalPais INT;
    
	DECLARE cursorPaises CURSOR FOR SELECT Name, Capital
									FROM Country
									WHERE Continent = continente;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucleCursor: LOOP
		FETCH cursorPaises INTO vNombrePais, vCapitalPais;
		IF finDatos = 1 THEN
			LEAVE bucleCursor;
		END IF;
        
        select vNombrePais, vCapitalPais;
    END LOOP bucleCursor;   
    
    
    CLOSE cursorPaises;
	


END$$