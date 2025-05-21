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
    DECLARE vPoblacion INT;
    DECLARE vSuperficie DECIMAL(10,2);
    DECLARE vNombre VARCHAR(52);
    DECLARE vPIB DECIMAL(10,2);
    
    DECLARE vDensidad DECIMAL(10,2);
    DECLARE vCualitativo VARCHAR(30);
    DECLARE vObservaciones VARCHAR(255);
    
	DECLARE cursorPaises CURSOR FOR SELECT Population, SurfaceArea, Name, GNP
									FROM Country
									WHERE GNP BETWEEN pibMinimo AND pibMaximo;
    -- EL HANDLER ES EL CATCH DE JAVA.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucleCursor: LOOP
		FETCH cursorPaises INTO vPoblacion, vSuperficie, vNombre, vPIB;
        -- Cuando no haya datos, entre estas dos instrucciones se ejecutará finDatos=TRUE.
		IF finDatos = TRUE THEN
			LEAVE bucleCursor;
		END IF;
        -- Lógica del procedimiento
        SET vDensidad = vPoblacion/vSuperficie;
        
        IF vDensidad > 1000 THEN
			SET vCualitativo = "Muy alta";
            SET vObservaciones = CONCAT("Alta concentración de población en ",vNombre," (",vPIB,")");
        ELSEIF vDensidad > 300 THEN
			SET vCualitativo = "Alta";
            SET vObservaciones = CONCAT("En ",vNombre," está densamente poblado (",vPIB,")");
        ELSEIF vDensidad > 50 THEN
			SET vCualitativo = "Media";
            SET vObservaciones = CONCAT(vNombre," tiene una población moderada (",vPIB,")");
        ELSE
			SET vCualitativo = "Baja";
            SET vObservaciones = CONCAT(vNombre," tiene regiones rurales poco habitadas, desiertos y/o montañas (",vPIB,")");
        END IF;
        
        -- INSERT
        INSERT INTO infoCalculada (caracteristica, cualitativo, cuantitativo, observaciones) 
        VALUES ("DensidadPoblación",vCualitativo,vDensidad,vObservaciones);
        -- FIN LÓGICA PARA CADA REGISTRO DE LA CONSULTA.
    END LOOP bucleCursor;
    CLOSE cursorPaises;
END$$

CALL registroDensidad(10,100)$$


DROP PROCEDURE IF EXISTS mostrarIdiomasPaises$$
CREATE PROCEDURE mostrarIdiomasPaises ()
BEGIN 
	-- PRIMERO SE DECLARAN VARIABLES
    DECLARE finDatos BOOLEAN DEFAULT FALSE;
    -- VARIABLES CURSOR PAÍSES.
    DECLARE vCodigoPais VARCHAR(3);
    DECLARE vNombre VARCHAR(52);
    DECLARE vPoblacion INT;
    -- VARIABLES CURSOR IDIOMAS.
    DECLARE vIdioma VARCHAR(30);
    DECLARE vCodigoPaisIdioma VARCHAR(3);
    DECLARE vPorcentaje DECIMAL(4,2);
    
    -- VARIABLES DE SALIDA
    DECLARE vChurro VARCHAR(255);
    DECLARE vCalculoPoblacion INT;
	DECLARE vContadorIdiomas INT DEFAULT 0;
    DECLARE vHayQueHacerFetch BOOLEAN DEFAULT TRUE;
 
    -- DESPUÉS, CURSORES Y HANDLER.
	DECLARE cursorPaises CURSOR FOR SELECT Code, Name, Population
									FROM Country
                                    -- para pruebas
                                    WHERE Code IN ("SPA","FRA","DEU","ZON")
                                    ORDER BY Code ASC;
    DECLARE cursorIdiomas CURSOR FOR SELECT Language, CountryCode, Percentage
									 FROM CountryLanguage
                                     -- para pruebas
                                     WHERE CountryCode IN ("SPA","FRA","DEU","ZON")
                                     ORDER BY CountryCode ASC, Percentage DESC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    OPEN cursorIdiomas;
    
    buclePaises: LOOP
		FETCH cursorPaises INTO vCodigoPais, vNombre, vPoblacion;
        IF finDatos = TRUE THEN
			LEAVE buclePaises;
        END IF;
        -- Para cada país.
        SET vChurro = CONCAT("En ", vNombre, " se habla ");
        SET vContadorIdiomas = 0;
        
        bucleIdiomas: LOOP
			-- Para tratar 
			IF vHayQueHacerFetch = TRUE THEN
				FETCH cursorIdiomas INTO vIdioma, vCodigoPaisIdioma, vPorcentaje;
			END IF;
            IF finDatos = TRUE THEN
				SET finDatos = FALSE;
				LEAVE bucleIdiomas;
			END IF;
            
            IF vCodigoPaisIdioma = vCodigoPais THEN
				SET vContadorIdiomas = vContadorIdiomas + 1;
				SET vCalculoPoblacion = vPorcentaje * vPoblacion / 100;
                SET vChurro = CONCAT(vChurro, vIdioma, "(",vCalculoPoblacion,") ,");
                SET vHayQueHacerFetch = TRUE;
            ELSE
				SET vHayQueHacerFetch = FALSE;
				LEAVE bucleIdiomas;
            END IF;     
            
        END LOOP bucleIdiomas;
		-- vChurro ya tiene todos los idiomas.
        IF vContadorIdiomas = 0 THEN
			SET vChurro = CONCAT(vNombre, " no tiene idiomas registrados");
        END IF;
        
        INSERT INTO infoCalculada  (caracteristica, cualitativo, cuantitativo, observaciones) 
        VALUES ("IdiomasPais",null,vContadorIdiomas,vChurro);
        
    END LOOP buclePaises;
    
    CLOSE cursorPaises;
    CLOSE cursorIdiomas;
END$$

CALL mostrarIdiomasPaises()$$

-- ESTRUCTURA "TIPO" DE PROCEDIMIENTO CON CURSOR
DROP PROCEDURE procedimientoTipoConCursor$$
-- Incluye entre paréntesis los parámetros si los hubiera.
CREATE PROCEDURE procedimientoTipoConCursor () 
BEGIN
	-- VARIABLE PARA PARAR EL CURSOR.
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    -- DECLARA VARIABLES PARA CURSOR Y RESTO FUNCIONAMIENTO
	DECLARE vEjemplo VARCHAR(255);
    
    -- MODIFICA LA CONSULTA QUE PIDA CADA CASO.
	DECLARE cursorTipo CURSOR FOR SELECT datoEjemplo FROM X;
    -- EL HANDLER ES EL CATCH DE JAVA.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorTipo;
    
    bucleCursor: LOOP
		-- Cambia vEjemplo por las variables que necesites.
		FETCH cursorTipo INTO vEjemplo;
        -- Cuando no haya datos, entre estas dos instrucciones se ejecutará finDatos=TRUE.
		IF finDatos = TRUE THEN
			LEAVE bucleCursor;
		END IF;
        -- Introduce aquí la lógica del procedimiento
        
    END LOOP bucleCursor;
    CLOSE cursorTipo;
    
    -- Introduce aquí la lógica resumen, o que se ejecuta tras tratar 
    -- todos los registros del cursor.
    
END$$


-- EJERCICIO 6
DROP PROCEDURE subidaImpuestos$$
-- Incluye entre paréntesis los parámetros si los hubiera.
CREATE PROCEDURE subidaImpuestos (IN continente enum('Asia','Europe','North_America','Africa','Oceania','Antarctica','South_America')) 
BEGIN
	-- VARIABLE PARA PARAR EL CURSOR.
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    -- DECLARA VARIABLES PARA CURSOR Y RESTO FUNCIONAMIENTO
	DECLARE vCode VARCHAR(3);
    DECLARE vGNP DECIMAL(10,2);
    DECLARE vFactor FLOAT;
    DECLARE vNumAumentados INT DEFAULT 0;
    DECLARE vNumReducidos INT DEFAULT 0;
    
    -- MODIFICA LA CONSULTA QUE PIDA CADA CASO.
	DECLARE cursorPaises CURSOR FOR SELECT GNP, Code
									FROM Country
                                    WHERE Continent = continente;
    -- EL HANDLER ES EL CATCH DE JAVA.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucleCursor: LOOP
		-- Cambia vEjemplo por las variables que necesites.
		FETCH cursorPaises INTO vGNP, vCode;
        -- Cuando no haya datos, entre estas dos instrucciones se ejecutará finDatos=TRUE.
		IF finDatos = TRUE THEN
			LEAVE bucleCursor;
		END IF;
        -- Introduce aquí la lógica del procedimiento
        IF vGNP > 500000 THEN
			SET vFactor = 0.95;
            SET vNumReducidos = vNumReducidos + 1;
        ELSEIF vGNP > 100000 THEN 
			SET vFactor = 0.98;
            SET vNumReducidos = vNumReducidos + 1;
        ELSE 
			SET vFactor = 1.03;
            SET vNumAumentados = vNumAumentados + 1;
        END IF;
        
		UPDATE Country
        SET GNPOld = GNP,
			GNP = GNP * vFactor
		WHERE Code = vCode;
        
    END LOOP bucleCursor;
    CLOSE cursorPaises;
    
    -- Introduce aquí la lógica resumen, o que se ejecuta tras tratar 
    -- todos los registros del cursor.
    INSERT INTO infoCalculada (caracteristica, cuantitativo, observaciones)
    VALUES ("SubidaImpuestos",vNumAumentados,vNumReducidos);
    
END$$

CALL subidaImpuestos("Europe")$$

DROP PROCEDURE recuentoIdiomasOficiales$$
CREATE PROCEDURE recuentoIdiomasOficiales(IN pRegion VARCHAR(26))
BEGIN
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    DECLARE vCodigo VARCHAR(3);
    DECLARE vNombre VARCHAR(52);
    DECLARE vContadorIdiomas INT;
    DECLARE vObservaciones VARCHAR(255);
    
    DECLARE cursorIdiomas CURSOR FOR SELECT Code, Name
									 FROM Country
                                     WHERE Region = pRegion;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorIdiomas;
    
    bucleCursor: LOOP
		FETCH cursorIdiomas INTO vCodigo, vNombre;
		IF finDatos = TRUE THEN
			LEAVE bucleCursor;
        END IF;
        
        SELECT Count(*)
        INTO vContadorIdiomas
        FROM CountryLanguage
        WHERE CountryCode = vCodigo
          AND IsOfficial = 'T';
        
        IF vContadorIdiomas = 3 THEN
			SET vObservaciones = CONCAT(vNombre, " es un país multicultural.");
        ELSEIF vContadorIdiomas < 3 THEN
			SET vObservaciones = CONCAT(vNombre, " tiene pocos idiomas oficiales.");
        ELSE 
			SET vObservaciones = CONCAT(vNombre, " tiene demasiados idiomas.");
        END IF;
        
        INSERT INTO infoCalculada (caracteristica, cualitativo, cuantitativo, observaciones)
        VALUES ("IdiomasOficiales",vCodigo,vContadorIdiomas,vObservaciones);
    END LOOP bucleCursor;
    
    CLOSE cursorIdiomas;
END$$

CALL recuentoIdiomasOficiales("Southern Europe")$$



DROP PROCEDURE IF EXISTS ajusteEsperanzaVida$$
CREATE PROCEDURE ajusteEsperanzaVida (IN pSuperficieMin DECIMAL(10,2),
									  IN pSuperficieMax DECIMAL(10,2))
BEGIN
	DECLARE finDatos BOOLEAN DEFAULT FALSE;
    DECLARE vEsperanza DECIMAL(3,1);
    DECLARE vPoblacion INT;
    DECLARE vSuperficie DECIMAL(10,2);
    DECLARE vCodigo VARCHAR(3);
    DECLARE vAnosAumentados INT DEFAULT 0;
    DECLARE vAnosDisminuidos INT DEFAULT 0;
    
    DECLARE cursorPaises CURSOR FOR SELECT LifeExpectancy, Population, SurfaceArea, Code
									FROM Country
                                    WHERE SurfaceArea BETWEEN pSuperficieMin AND pSuperficieMax
                                      AND LifeExpectancy IS NOT NULL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN cursorPaises;
    
    bucle: LOOP
		FETCH cursorPaises INTO vEsperanza, vPoblacion, vSuperficie, vCodigo;
        IF finDatos = TRUE THEN
			LEAVE bucle;
        END IF;
		
        IF vPoblacion > 100000000 THEN
			SET vEsperanza = vEsperanza - 3;
            SET vAnosDisminuidos = vAnosDisminuidos - 3;
        ELSEIF vPoblacion > 50000000 THEN
			SET vEsperanza = vEsperanza - 1;
            SET vAnosDisminuidos = vAnosDisminuidos - 1;
        ELSEIF vPoblacion < 10000000 THEN
			SET vEsperanza = vEsperanza + 2;
			SET vAnosDisminuidos = vAnosDisminuidos + 2;
        END IF;        
        
        UPDATE Country
        SET LifeExpectancy = vEsperanza
        WHERE Code = vCodigo;
        
    END LOOP bucle;

	CLOSE cursorPaises;
    
    INSERT INTO infoCalculada (caracteristica, cuantitativa, observaciones)
    VALUES ("esperanzaModificada",vAnosAumentados,vAnosDisminuidos);
END$$

CALL ajusteEsperanzaVida(10000,12000)$$

