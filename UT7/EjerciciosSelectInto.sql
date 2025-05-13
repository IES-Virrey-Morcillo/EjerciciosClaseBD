DELIMITER ;
DROP DATABASE IF EXISTS noticias;
CREATE DATABASE noticias;
USE noticias;

-- Ejemplo 5.19
CREATE TABLE noticia (
	id INT PRIMARY KEY auto_increment,
    titulo VARCHAR(200),
    contenido TEXT,
    fecha date
);

INSERT INTO noticia (titulo, contenido, fecha) VALUES 
	("La Pantoja se casa","Pantoja se enamora",current_date()),
    ("La Jesulín se casa","Jesulín se encariña","2020-01-01"),
    ("La Jorge se casa","Jorge se enfada",current_date()+2);

DELIMITER $$
DROP PROCEDURE IF EXISTS obtenerDatosNoticia$$
CREATE PROCEDURE obtenerDatosNoticia(idNoticia INT)
BEGIN
	DECLARE vId INT DEFAULT NULL;
    DECLARE vTitulo VARCHAR(200);
    DECLARE vContenido TEXT;
    DECLARE vFecha DATE;
    -- Variables para colocar el número de días que hace/dentro de.
    DECLARE vHoy DATE DEFAULT current_date();
    DECLARE diferenciaDias INT DEFAULT 0;
    DECLARE textoFecha VARCHAR(30);

	IF idNoticia IS NULL THEN
		SELECT "El id de noticia no puede ser nulo" 
				as Aviso;
    ELSE 

		SELECT id, titulo, contenido, fecha
		INTO vId, vTitulo, vContenido, vFecha
		FROM noticia;
		
		IF vId IS NULL THEN
			SELECT CONCAT("La noticia con ID ",idNoticia,
						  " no existe.") as Aviso;
		ELSE
			SET diferenciaDias = DATEDIFF(vHoy, vFecha);

			IF diferenciaDias = 0 THEN
				SET textoFecha = ". Hoy.";
			ELSEIF diferenciaDias > 0 THEN
				SET textoFecha = CONCAT(". Hace ",diferenciaDias," dias.");
			ELSE 
				SET textoFecha = CONCAT(". Dentro de ",ABS(diferenciaDias)," dias.");
			END IF;    
			
			SELECT CONCAT("Titulo: ", vTitulo, 
			". Contenido: ", vContenido, textoFecha)
			as NoticiaFormateada;
		END IF;
	END IF;
END$$

CALL obtenerDatosNoticia(1)$$
CALL obtenerDatosNoticia(2)$$
CALL obtenerDatosNoticia(3)$$
CALL obtenerDatosNoticia(23456)$$
CALL obtenerDatosNoticia(null)$$

-- Ejercicio 1.
DROP PROCEDURE IF EXISTS fijandoPoblacionZonaRural$$
CREATE PROCEDURE fijandoPoblacionZonaRural 
								(IN codPais VARCHAR(3))
BEGIN
	DECLARE mediaPoblacion INT;
    DECLARE numeroCiudades INT;
    
    IF codPais IS NULL THEN
		SELECT "El código de país debe informarse" AS AVISO;
    ELSE 
		
		SELECT AVG(Population), COUNT(*)
		INTO mediaPoblacion, numeroCiudades
		FROM City
		WHERE CountryCode = codPais;
		
        IF numeroCiudades > 0 THEN 
			UPDATE City
			SET Population = Population * 1.2
			WHERE Population < mediaPoblacion 
			  AND CountryCode = codPais;
		ELSE 
			SELECT CONCAT("El país ", codPais, " no tiene ciudades");
        END IF;
	END IF;
END$$

CALL fijandoPoblacionZonaRural("AFG")$$
CALL fijandoPoblacionZonaRural("COR")$$


# Desarrolla una función que reciba como parámetro un código de ciudad.
# La función deberá devolver el resultado de concatenar el distrito de la ciudad,
# con la región del país y el continente.
DELIMITER $$
DROP FUNCTION IF EXISTS concatenarDatosPais$$
CREATE FUNCTION concatenarDatosPais (codCiudad INT)
RETURNS VARCHAR(255)
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE vDistrito VARCHAR(20);
    DECLARE vRegion VARCHAR(26);
    # Podríamos declarar vContinente como VARCHAR(15).
    DECLARE vContinente enum('Asia','Europe','North_America','Africa','Oceania','Antarctica','South_America');
	DECLARE vCodPais VARCHAR(3) DEFAULT NULL;
    
	IF codCiudad IS NULL THEN
		RETURN 'Hay que informar el ID de ciudad';
	ELSE
		SELECT District, CountryCode
		INTO vDistrito, vCodPais
		FROM City
		WHERE id = codCiudad;
		
        IF vCodPais IS NULL THEN
			RETURN 'La ciudad no existe';
        ELSE
			SELECT Region, Continent
			INTO vRegion, vContinente
			FROM Country
			WHERE Code = vCodPais;
			
			RETURN CONCAT(vDistrito, " - ", vRegion, " - ", vContinente);
        END IF;
	END IF;
END$$

SELECT concatenarDatosPais(653), concatenarDatosPais(31), 
       concatenarDatosPais(9999), concatenarDatosPais(null)$$




#Desarrolla una función que recibe un idioma y un código de país como parámetros.
#La función devolverá un mensaje de texto en función de: si el idioma no se habla en el país,devolverá "El idioma <idioma> no se habla en <nombrePaís>;
#si el idioma es oficial, "El idioma <idioma> es oficial en <nombrePaís> y lo hablan X personas;
# si el idioma no es oficial, "El idioma <idioma> no es oficial en <nombrePaís>, aunque lo hablan X personas.
#Para obtener las personas, se multiplicará el porcentaje de habla por la población del país.



DROP FUNCTION comprobarIdiomaPais$$
CREATE FUNCTION comprobarIdiomaPais (idioma VARCHAR(30), codPais VARCHAR(3))
RETURNS VARCHAR(255)
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE vPorcentaje DECIMAL(4,1); -- Tabla CountryLanguage
    DECLARE vEsOficial ENUM('T','F'); -- Tabla CountryLanguage
    
    DECLARE vPoblacion INT; -- Tabla Country
    DECLARE vNombrePais VARCHAR(52); -- Tabla Country
    
	DECLARE vHablantes INT; -- Calculado
    DECLARE vMensaje VARCHAR(255); -- Calculado
    
    IF codPais IS NULL OR idioma IS NULL THEN
		SET vMensaje = "Ni el idioma ni el codigo de pais puede ser nulo";
    ELSE 
    
		SELECT IsOfficial, Percentage
		INTO vEsOficial, vPorcentaje
		FROM CountryLanguage
		WHERE CountryCode = codPais
		  AND Language = idioma;
		
		SELECT Name, Population
		INTO vNombrePais, vPoblacion
		FROM Country
		WHERE Code = codPais;
		
		IF vEsOficial IS NULL THEN
			-- No se habla el idioma en el país, o el país no existe.
			IF vNombrePais IS NULL THEN
				-- El país no existe.
				SET vMensaje = CONCAT("El pais no existe: ", codPais);
			ELSE
				-- El país existe, pero el idioma no se habla.
				SET vMensaje = CONCAT("El idioma ",idioma," no se habla en ", vNombrePais);
			END IF;
		ELSE
			-- El idioma se habla en el país.
			SET vHablantes = vPoblacion * (vPorcentaje / 100);
			IF vEsOficial = 'T' THEN 
				-- Lenguaje oficial
				SET vMensaje = CONCAT("El idioma ",idioma," es oficial en ", vNombrePais,
				" y lo hablan ",vHablantes," personas.");
			ELSE
				-- Lenguaje no oficial
				SET vMensaje = CONCAT("El idioma ",idioma," no es oficial en ", vNombrePais,
				", aunque lo hablan ",vHablantes," personas.");
			END IF;
		END IF;
    END IF;
    RETURN vMensaje;
END$$

SELECT comprobarIdiomaPais('Castellano','SPA'),
	   comprobarIdiomaPais('Catalan','SPA'),
       comprobarIdiomaPais('Inglés','SPA'),
       comprobarIdiomaPais('Castellano','XYZ'),
       comprobarIdiomaPais(null,null);

-- Lo bueno de las funciones.
SELECT comprobarIdiomaPais(Language,CountryCode)
FROM CountryLanguage;

