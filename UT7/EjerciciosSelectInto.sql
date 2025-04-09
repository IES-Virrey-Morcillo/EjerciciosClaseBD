DELIMITER ;
DROP DATABASE IF EXISTS noticias;
CREATE DATABASE noticias;
USE noticias;

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