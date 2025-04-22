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
		FROM noticia
		WHERE id = idNoticia;
		
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
# La función deberá devolver el resultado de concatenar el distrito de la ciudad, con la región del país y el continente.





#Desarrolla una función que recibe un idioma y un código de país como parámetros.
#La función devolverá un mensaje de texto en función de: si el idioma no se habla en el país,devolverá "El idioma <idioma> no se habla en <nombrePaís>;
#si el idioma es oficial, "El idioma <idioma> es oficial en <nombrePaís> y lo hablan X personas;
# si el idioma no es oficial, "El idioma <idioma> no es oficial en <nombrePaís>, aunque lo hablan X personas.
#Para obtener las personas, se multiplicará el porcentaje de habla por la población del país.