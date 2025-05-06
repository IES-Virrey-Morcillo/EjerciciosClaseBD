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
    DECLARE churro VARCHAR(255);
    
	DECLARE cursorPaises CURSOR FOR SELECT Name, Capital
									FROM Country
									WHERE Continent = continente
                                      AND Capital IS NOT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucleCursor: LOOP
		FETCH cursorPaises INTO vNombrePais, vCapitalPais;
		IF finDatos = 1 THEN
			LEAVE bucleCursor;
		END IF;
        -- Lógica del procedimiento
        SELECT CONCAT("La capital de ",vNombrePais," es ",Name,", y viven ",Population," personas")
        INTO churro
        FROM City
        WHERE ID = vCapitalPais;
        
        INSERT INTO auditoria (nombre,fechahora) VALUES (churro,current_timestamp());
    END LOOP bucleCursor;   
    CLOSE cursorPaises;
    SELECT * FROM auditoria;
    DELETE FROM auditoria;
END$$

CALL poblacionCapitales("North_America")$$

DROP PROCEDURE IF EXISTS exodoInverso $$
CREATE PROCEDURE exodoInverso (in pRegion varchar(26))
BEGIN 
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    DECLARE vID INT;
    DECLARE vNombre VARCHAR(50);
    DECLARE vPoblacion INT;
    DECLARE vFactor FLOAT;
    DECLARE vContador INT DEFAULT 0;
    
	DECLARE cursorCiudades CURSOR FOR SELECT ci.ID, ci.Name, ci.Population
									  FROM City ci
                                      INNER JOIN Country co ON co.Code = ci.CountryCode
                                      WHERE co.Region = pRegion;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorCiudades;
    
    bucleCursor: LOOP
		FETCH cursorCiudades INTO vID, vNombre, vPoblacion;
		IF finDatos = 1 THEN
			LEAVE bucleCursor;
		END IF;
        -- Lógica del procedimiento
        SET vContador = vContador + 1;
        IF vPoblacion >= 1000000 THEN
			SET vFactor = 0.9;
        ELSEIF vPoblacion >= 500000 THEN
			SET vFactor = 0.95;
        ELSEIF vPoblacion >= 250000 THEN
			SET vFactor = 1.1;
        ELSE
			SET vFactor = 1.2;
        END IF;
		UPDATE city 
        SET Population = Population * vFactor
        WHERE ID = vID;
    END LOOP bucleCursor;   
    CLOSE cursorCiudades;
    SELECT CONCAT("Se han actualizado ",vContador," ciudades.");
END$$

CALL exodoInverso("Caribbean")$$
CALL exodoInverso("NoExiste")$$


CREATE TABLE infoCalculada (
	id INT PRIMARY KEY AUTO_INCREMENT,
    caracteristica VARCHAR(30) NOT NULL,
    cualitativo VARCHAR(30),
    cuantitativo DECIMAL(10,2),
    observaciones VARCHAR(255),
    auditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)$$

DROP PROCEDURE IF EXISTS registroDensidad $$
CREATE PROCEDURE registroDensidad (in pibMinimo DECIMAL(10,2), IN pibMaximo DECIMAL(10,2))
BEGIN 
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    
	DECLARE cursorPaises CURSOR FOR SELECT -- Poco a poco lo iré completando
									FROM Country
									WHERE GNP BETWEEN pibMinimo AND pibMaximo;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucleCursor: LOOP
		FETCH cursorPaises INTO -- 
		IF finDatos = TRUE THEN
			LEAVE bucleCursor;
		END IF;
        -- Lógica del procedimiento
        
        -- insert 
    END LOOP bucleCursor;   
    CLOSE cursorPaises;
END$$