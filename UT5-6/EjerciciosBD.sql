-- 6. Mostrar el nombre de los países que no tienen forma de gobierno 'Republic'.
SELECT *
FROM Country
WHERE GovernmentForm != 'Republic';

-- 7.Obtener todas las ciudades que empiecen con 'San', ordenadas por 
-- población de mayor a menor. Solo las 6 primeras.
SELECT *
FROM city
WHERE Name LIKE 'S_n%'
 AND District = 'La Mancha'
ORDER BY Population DESC
LIMIT 600;

-- 8. Listar las ciudades de 'France', 'Germany' o 'Italy'.
SELECT *
FROM City
WHERE CountryCode = 'FRA' 
   OR CountryCode = 'DEU' 
   OR CountryCode =  'ITA';
   
SELECT *
FROM City
WHERE CountryCode IN ('FRA', 'DEU', 'ITA');


-- 9. Mostrar nombre, región y esperanza de vida de
--  los países del continente 'Asia' 
-- con más de 50 millones de habitantes y que tengan una forma 
-- de gobierno 'Republic'.
SELECT Name, Region, LifeExpectancy
FROM Country
WHERE Continent = 'Asia'
  AND GovernmentForm = 'Republic'
  AND Population > 50000000;
  


-- 10. Ordenar los países por PIB (GNP) de mayor a menor.
SELECT *
FROM Country
ORDER BY gnp DESC; 
-- 11. Ordenar las ciudades de España por población en orden descendente.
SELECT *
FROM City
WHERE CountryCode = 'ESP'
ORDER BY Population DESC
LIMIT 10;
-- 12. Listar las lenguas habladas en España ('ESP') ordenadas 
-- alfabéticamente.
SELECT *
FROM CountryLanguage
WHERE CountryCode = 'ESP'
ORDER BY Percentage DESC;


SELECT * FROM CITY;

-- Cuánta gente hay en el mundo (según la población de sus ciudades).
SELECT SUM(Population)
FROM city;
-- Cuánta gente hay en el mundo (según la población de sus países).
SELECT SUM(Population)
FROM Country;
-- Cuánta gente hay en ESPAÑA (según la población de sus ciudades).
SELECT SUM(Population)
FROM city
WHERE CountryCode = "ESP";
-- ¿Cuántas ciudades hay?
SELECT COUNT(*)
FROM City;
-- ¿Cuántos países hay?
SELECT COUNT(*)
FROM Country;
-- ¿Qué población tiene la ciudad más grande? ¿Y la más pequeña?
SELECT max(population), min(population)
FROM City;
-- ¿Cuál es la media de población de los países?
SELECT AVG(Population)
FROM Country;
-- Obtén el total de la población de las ciudades de España agrupando
-- por distrito.
SELECT District, sum(Population) as suma_poblacion
FROM City
WHERE CountryCode = "ESP"
GROUP BY District
ORDER BY suma_poblacion;

-- 24. Obtener el número total de países por continente.
SELECT Continent, count(*)
FROM Country
GROUP BY Continent;

-- 25. Calcular la población total de cada continente
SELECT Continent, SUM(Population), COUNT(Population)
FROM Country
GROUP BY Continent;

DELETE FROM Country
WHERE Continent = 'Antarctica';


-- 26. Obtener el país con mayor población en cada continente
SELECT Continent, Name, Population
FROM country
where Population IN (SELECT MAX(Population)
					 FROM Country
					 GROUP BY Continent);

-- 27. Mostrar la cantidad de ciudades registradas 
-- en cada país.
SELECT CountryCode, COUNT(*)
FROM City
GROUP BY CountryCode;

-- 28. Obtener el idioma más hablado en cada 
-- país (según porcentaje).
SELECT CountryCode, Language
FROM CountryLanguage 
WHERE (CountryCode, Percentage) IN (SELECT CountryCode, MAX(Percentage)
									FROM CountryLanguage
									GROUP BY CountryCode);
                                    
                                    
-- 29. Calcular el PIB (GNP) medio de los países de cada continente
SELECT Continent, AVG(GNP) as MediaGNP
FROM Country
GROUP BY Continent;

-- 30. Listar los continentes donde el PIB medio de los países 
-- sea superior a 100.000 (usar HAVING).
SELECT Continent, AVG(GNP) as MediaGNP
FROM Country
GROUP BY Continent
HAVING MediaGNP > 100000;

-- 31. Mostrar los países con un número de ciudades superior 
-- a 10 (usar HAVING).
SELECT CountryCode, count(*) as total
FROM City
GROUP BY CountryCode
HAVING total > 10;

-- 32. Obtener el porcentaje medio de hablantes de cada idioma 
-- en todos los países donde se hable.

SELECT Language, AVG(Percentage)
FROM CountryLanguage
GROUP BY Language;

-- 33. Listar los continentes y su población total, mostrando 
-- solo aquellos con más de 1,000 millones de habitantes.
SELECT Continent, SUM(Population) as TotalPoblacion
FROM Country
GROUP BY Continent
HAVING TotalPoblacion > 1000000000;


-- 34. CIUDAD JUNTO CON PAÍS
SELECT ci.Name as NombreCiudad, 
	   co.Name as NombrePais
FROM City ci
INNER JOIN Country co ON co.code = ci.countrycode;

-- 35. Listar todos los países junto con sus
--  idiomas oficiales.
SELECT co.Name, cl.language, cl.IsOfficial
FROM Country co
INNER JOIN CountryLanguage cl 
 ON co.code = cl.countrycode
WHERE cl.IsOfficial = 'T';

-- 35b. Mostrar el idioma oficial que se habla en cada
-- ciudad junto con el continente.

SELECT ci.name as Ciudad, cl.language as idioma, co.continent as Continente
FROM City ci
INNER JOIN Country co ON co.code = ci.countrycode
INNER JOIN CountryLanguage cl ON co.code = cl.countrycode
WHERE cl.IsOfficial = 'T';

-- 35c. ¿Cuántos idiomas oficiales se hablan en cada 
-- ciudad?
SELECT ci.name as Ciudad, ci.countrycode, count(cl.language)
FROM City ci
INNER JOIN CountryLanguage cl ON ci.countrycode = cl.countrycode
WHERE cl.IsOfficial = 'T'
GROUP BY ci.id;

-- 35d. Muestra el número de personas que hablan
-- cada idioma en cada ciudad del Continente Europa.
SELECT co.name, ci.name, ci.population, cl.language, cl.percentage,
       ROUND(ci.population*cl.percentage/100) as Personas
FROM City ci
INNER JOIN Country co ON co.code = ci.countrycode
INNER JOIN CountryLanguage cl ON cl.countrycode = co.code
WHERE co.Continent = 'Europe' AND co.code = 'ESP'
ORDER BY co.code, ci.id;

-- 36. Mostrar los países que no tienen ciudades
-- registradas en la base de datos
SELECT co.*
FROM Country co
LEFT JOIN City ci ON ci.CountryCode = co.Code
WHERE ci.id IS NULL;

-- 37 Obtener los países junto con sus respectivas capitales.
SELECT co.name as pais, ci.name as capital
FROM Country co
LEFT JOIN City ci ON ci.id = co.capital;

-- 38. Listar las ciudades que no tienen país asociado (usar RIGHT JOIN).
SELECT ci.*
FROM Country co
RIGHT JOIN City ci ON ci.CountryCode = co.code
WHERE co.Code IS NULL;


-- SAKILA
-- Nombre de actor junto con las películas en las que participa.
SELECT a.first_name, a.last_name, f.title
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
ORDER BY f.title;

-- Idiomas en los que ha trabajado un actor (dando nombre de actor).
SELECT DISTINCT a.first_name, a.last_name, l.name
FROM language l
INNER JOIN film f ON l.language_id = f.language_id
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
ORDER BY a.first_name, a.last_name;

-- Nombre de película y categorías de cada película desde 1980 hasta el 2000


-- NOMBRE Y APELLIDOS DE CLIENTE JUNTO CON EL PAÍS EN EL QUE VIVE.
SELECT cu.first_name, cu.last_name, co.country
FROM country co
INNER JOIN city ci ON co.country_id = ci.country_id
INNER JOIN address a ON ci.city_id = a.city_id
INNER JOIN customer cu ON cu.address_id = a.address_id
ORDER BY cu.last_name, cu.first_name;

-- Nombre de idioma junto con las películas en las
-- que se usa, y los idiomas que no se usan en 
-- ninguna película.
SELECT l.name, f.title
FROM language l
LEFT JOIN film f ON l.language_id = f.language_id;


-- QUIERO LAS DIRECCIONES JUNTO CON SU CIUDAD,
-- Y LAS CIUDADES EN LAS QUE NO HAY NINGUNA 
-- DIRECCIÓN.
SELECT ci.city, ad.address
FROM address ad RIGHT JOIN city ci ON ci.city_id = ad.city_id;

SELECT ci.city, ad.address
FROM city ci 
JOIN address ad ON ci.city_id = ad.city_id
WHERE ad.address_id IS NULL;



-- Actores (nombre, apellidos) que hayan participado 
-- en más de 30  películas, ordenados por nombre.
-- Incluye el número de películas (numPelis).
SELECT a.actor_id, a.first_name, a.last_name, count(*)
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id
HAVING count(*) > 30
ORDER BY a.first_name;

-- Máxima duración de una película, mínima duración, duración
-- media, recuento de películas, suma de minutos de peliculas.
-- Añade alias a cada resultado.
SELECT rating, MAX(length) as maximo, 
	   MIN(length) as minimo, 
       AVG(length) as media, 
       COUNT(*) as recuentoTotal, 
       count(length) as recuentoLongitud,
	   SUM(length) as sumaMinutos
FROM film
GROUP BY rating;

-- Actores que no han participado en ninguna película.
SELECT a.first_name, fa.film_id
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
order by film_id; 


-- 52. Obtener los países cuya población sea mayor que la población media de todos los países.


-- Listar las ciudades cuya población sea mayor que la población de la capital de España.


-- 54. Mostrar los países de américa que tienen más habitantes que el 
-- máximo de población de un país europeo.
SELECT *
FROM Country
WHERE (Continent = 'South_America' 
  OR Continent = 'North_America')
  AND Population > (SELECT MAX(Population) 
					FROM Country 
					WHERE Continent = 'Europe');

-- 55. Obtener las ciudades que tienen más población que la ciudad 
-- más poblada de Italia.
SELECT * 
FROM City
WHERE Population > (SELECT MAX(Population)
					FROM City
					WHERE CountryCode = (SELECT Code 
										 FROM Country
										 WHERE Name = 'Italy'));
-- 55B. Obtener las ciudades de distritos que empiezan por A 
-- que tienen más población que la ciudad media de las ciudades de España y 
-- Francia.

SELECT Name, District, Population
FROM City
WHERE District LIKE 'A%'
  AND Population > (SELECT AVG(Population) 
					FROM City
                    WHERE CountryCode IN (SELECT Code 
										  FROM Country
                                          WHERE Name IN ("Spain","France")));


-- 56. Listar los países que tienen el PIB (GNP) máximo de su continente.
SELECT Name, GNP, Continent
FROM Country 
WHERE (Continent, GNP) IN (SELECT Continent, MAX(GNP) 
						   FROM Country
			               GROUP BY Continent);


-- 57. Ciudades con una población mayor a la capital de España
SELECT *
FROM City
WHERE Population > (SELECT Population 
					FROM City 
                    WHERE ID = (SELECT capital 
								FROM Country 
								WHERE Name = "Spain"));


-- 58. Idiomas oficiales de países con PIB per cápita superior a 20.000
SELECT *
FROM CountryLanguage
WHERE IsOfficial = 'T'
  AND CountryCode IN (SELECT Code
					  FROM country
                      WHERE GNP > 20000);

-- 59. Países donde se habla español como idioma oficial
SELECT *
FROM Country
WHERE Code IN (SELECT CountryCode
			   FROM CountryLanguage
               WHERE IsOfficial = 'T' AND Language = 'Spanish');

-- 60 Ciudades de países con una población mayor a 100 millones
SELECT *
FROM City
WHERE CountryCode IN (SELECT Code
					  FROM Country
                      WHERE Population > 100000000);
                      
-- 61. Países donde NO se habla inglés oficialmente.
SELECT *
FROM Country
WHERE Code NOT IN (SELECT CountryCode
			       FROM CountryLanguage
                   WHERE IsOfficial = 'T' 
                     AND Language = 'English');
                     
-- 61B. Ciudades donde NO se habla inglés oficialmente.
SELECT *
FROM City
WHERE CountryCode NOT IN (SELECT CountryCode
						  FROM CountryLanguage
                          WHERE IsOfficial = 'T' 
                            AND Language = 'English');   
                            
-- 62. Países que no tienen una capital registrada en la tabla city
SELECT *
FROM country
WHERE capital IS NULL;

-- 63. Clientes que han alquilado alguna película.
SELECT *
FROM customer
WHERE customer_id IN (SELECT customer_id
					  FROM rental);
-- 63B. cLIENTES QUE TENGAN AUN ALGUNA PELICULA ALQUILADA.
SELECT *
FROM customer
WHERE customer_id IN (SELECT customer_id
					  FROM rental
                      WHERE return_date IS NULL);
                      
-- 64. Películas que no han sido alquiladas.


/*
Villarrobledo (Castilla-La Mancha, 25,000 habitantes).
Alcázar de San Juan (Castilla-La Mancha, 30,000 habitantes).
Tomelloso (Castilla-La Mancha, 36,000 habitantes).
La Roda (Castilla-La Mancha, 15,000 habitantes).
*/
INSERT INTO City (Name, CountryCode, Population, District)
VALUES ('Villarrobledo','ESP', 25000,'Castilla-La Mancha'),
       ('Alcázar de San Juan','ESP', 30000,'Castilla-La Mancha');
       
INSERT INTO City (Name, CountryCode, Population)
VALUES ('Tomelloso','ESP',36000);
ALTER TABLE City DROP foreign key city_ibfk_1;
ALTER TABLE City MODIFY COLUMN CountryCode VARCHAR(3) NULL;
ALTER TABLE City ADD foreign key (CountryCode) 
REFERENCES Country (Code)
ON UPDATE CASCADE ON DELETE RESTRICT;

INSERT INTO City (Name, District, Population)
VALUES ('La Roda', 'Castilla-La Mancha',15000);

-- Noverland (Código: NVL, Europa, Utopía del Norte, 500,000 
-- km², 5,000,000 habitantes, PIB: 80,000).
INSERT INTO Country 
(Code, Name, Continent, Region, SurfaceArea, Population, GNP)
VALUES ('NVL','Noverland','Europe','Utopía del Norte', 
500000, 5000000,80000),
('TRN','Terranova','North_America','Región del Nuevo Mundo', 
750000, 8000000,120000),
('ZON','Zionia','Asia','Archipiélago Místico', 
300000, 3500000,60000);
/*
Zionia (ZON)
9. Shan'Li (Capital, 750,000 habitantes).
10. Bao'Ming (Ciudad comercial, 500,000 habitantes).
*/

INSERT INTO City (Name, District, Population, CountryCode) VALUES
('Shan\'Li','Capital',750000,'ZON'),
("Bao'Ming",'Ciudad comercial',500000,'ZON');

-- Novariano (Se habla en Noverland, idioma oficial,
-- 95% de hablantes).
INSERT INTO CountryLanguage
VALUES ('NVL','Novariano','T',95);
-- Zionés (Se habla en Zionia, idioma oficial, 92% de hablantes).
INSERT INTO CountryLanguage
VALUES ('ZON','Zionés','T',92);

-- Aumentar la población de Villarrobledo
UPDATE City
SET Population = Population + 1500
WHERE Name = 'Villarrobledo';

-- Disminuye la población de las ciudades de España un 15%
UPDATE City
SET Population = Population * 0.85
WHERE CountryCode IN (SELECT Code FROM Country
					 WHERE Name = "Spain");


-- INSERTO UN PAÍS FICTICIO
INSERT INTO Country 
(Code, Name, Continent, Region, SurfaceArea, Population, GNP)
VALUES ('DAW','transicion','Europe','Utopía del Norte', 
500000, 5000000,80000);
-- CAMBIAR LAS CIUDADES DE ESP A DAW
UPDATE City
SET CountryCode = 'DAW'
WHERE CountryCode = 'ESP';
-- CAMBIAR LAS LENGUAS A DAW
UPDATE CountryLanguage
SET CountryCode = 'DAW'
WHERE CountryCode = 'ESP';
-- Cambia el código del país ESP por SPA.
UPDATE Country
SET Code = 'SPA'
WHERE Code = 'ESP';
-- RESTAURAR LAS CIUDADES DE DAW A SPA
UPDATE City
SET CountryCode = 'SPA'
WHERE CountryCode = 'DAW';
-- RESTAURAR LAS LENGUAS A SPA
UPDATE CountryLanguage
SET CountryCode = 'SPA'
WHERE CountryCode = 'DAW';
-- ELIMINAR PAIS DE TRANSICIÓN
DELETE FROM Country WHERE Code = 'DAW';



-- Actualizar la lengua oficial de Zionia
UPDATE CountryLanguage
SET Language = 'Neo-Zionés'
WHERE CountryCode = 'ZON' and Language = 'Zionés';


-- Incrementar el PIB de Terranova un 10%
UPDATE Country
SET GNP = GNP * 1.1
WHERE Name = 'Terranova';



-- Código: AUR, Oceanía, Confederación del Sol, 450,000 km², 6,500,000 habitantes, PIB: 90,000).
INSERT INTO Country (Code, Name, Continent, Region, SurfaceArea, Population, GNP) 
VALUES ('AUR', 'Auroria', 'Oceania', 'Confederación del Sol', 450000, 6500000, 90000);
-- Actualizar la región de Auroria

UPDATE Country 
SET Region = 'Federación Auroriana'
WHERE Code = 'AUR';


-- Ejercicios de DELETE
-- 1️⃣ Eliminar la ciudad de La Roda
DELETE FROM City
WHERE ID = 1889;

select *
from city
where name = 'York';



-- España ha conquistado Marte. Y ha fundado una ciudad nueva por cada una
-- de las ciudades que tiene actualmente en España con el 10% de la población
-- de cada una de ellas, y además bautizando el distrito de la ciudad de igual
-- manera. El nuevo país será una colonia llamada Auroria.
ALTER TABLE City MODIFY COLUMN Name VARCHAR(50) NOT NULL DEFAULT '';
INSERT INTO City (Name, CountryCode, District, Population) 
(SELECT CONCAT("Renovado ",Name), 'AUR', District, Population * 0.1
 FROM City WHERE CountryCode = 'SPA');
 
 
 -- Actualiza donde ponga Renovado X, que ponga Nuevo X en todas las
-- ciudades del país AUR. USA REPLACE.
SELECT *, REPLACE(Name, 'Renovado', 'Nuevo') as NuevoNombre, ucase(Name)
FROM city 
WHERE CountryCode = 'AUR';

UPDATE City
SET Name = REPLACE(Name, 'Renovado', 'Nuevo')
WHERE CountryCode = 'AUR';


-- Eliminar todas las ciudades cuya población sea menor que la población 
-- media de todas las ciudades.
DELETE FROM City
WHERE Population < (SELECT avg(POPULATION) from (SELECT AVERAGE_POPULATION FROM (SELECT avg(POPULATION) AS AVERAGE_POPULATION from City)));
-- Aumentar en un 10% la población de todas las ciudades que tengan más 
-- habitantes que la ciudad más poblada de Francia.
-- Borrar todos los idiomas que no sean oficiales y que tengan un 
-- porcentaje menor que el promedio de todos los idiomas no oficiales.

/*
Las antiguas ciudades de Grecia vuelven a su antigua organización, 
ciudades-estado. Incluye estos nuevos estados en la tabla Country, 
de la siguiente manera: con la población de la ciudad como la población 
del país, el distrito de la ciudad como región, el continente Europe, 
la superficie será la división entre la superficie de GRC (Grecia) 
entre el número de ciudades de Grecia, el año de indepenencia será el 
año actual (usando las funciones YEAR y CURRENT_DATE), la esperanza de
 vida será la misma que el país GRC, la forma de gobierno será república,
 y la capital, el ID de la ciudad original. El código de país será una X
 concatenada con las dos primeras letras del nombre de la ciudad. 
 El resto de campos de Country, por defecto. 
 */
INSERT INTO Country (Name, Population, Region, Code, Continent, 
					 IndepYear, GovernmentForm, Capital,LifeExpectancy,
                     SurfaceArea) 
(
 SELECT Name, Population, District, CONCAT('X',LEFT(Name,2)), 'Europe',
		YEAR(CURRENT_DATE()), 'Republic', ID, 
        (SELECT LifeExpectancy FROM world.country WHERE Code = 'GRC'),
        (SELECT SurfaceArea / (SELECT COUNT(*)
							   FROM City 
							   WHERE CountryCode = 'GRC')
		 FROM Country
		 WHERE Code = 'GRC')
 FROM City 
 WHERE CountryCode = 'GRC'
);

/*
Villarrobledo (Castilla-La Mancha, 25,000 habitantes).
Alcázar de San Juan (Castilla-La Mancha, 30,000 habitantes).
Tomelloso (Castilla-La Mancha, 36,000 habitantes).
La Roda (Castilla-La Mancha, 15,000 habitantes).
*/
INSERT INTO City (Name, CountryCode, Population, District)
VALUES ('Villarrobledo','ESP', 25000,'Castilla-La Mancha'),
       ('Alcázar de San Juan','ESP', 30000,'Castilla-La Mancha');
       
INSERT INTO City (Name, CountryCode, Population)
VALUES ('Tomelloso','ESP',36000);
ALTER TABLE City DROP foreign key city_ibfk_1;
ALTER TABLE City MODIFY COLUMN CountryCode VARCHAR(3) NULL;
ALTER TABLE City ADD foreign key (CountryCode) 
REFERENCES Country (Code)
ON UPDATE CASCADE ON DELETE RESTRICT;

INSERT INTO City (Name, District, Population)
VALUES ('La Roda', 'Castilla-La Mancha',15000);

-- Noverland (Código: NVL, Europa, Utopía del Norte, 500,000 
-- km², 5,000,000 habitantes, PIB: 80,000).
INSERT INTO Country 
(Code, Name, Continent, Region, SurfaceArea, Population, GNP)
VALUES ('NVL','Noverland','Europe','Utopía del Norte', 
500000, 5000000,80000),
('TRN','Terranova','North_America','Región del Nuevo Mundo', 
750000, 8000000,120000),
('ZON','Zionia','Asia','Archipiélago Místico', 
300000, 3500000,60000);
/*
Zionia (ZON)
9. Shan'Li (Capital, 750,000 habitantes).
10. Bao'Ming (Ciudad comercial, 500,000 habitantes).
*/

INSERT INTO City (Name, District, Population, CountryCode) VALUES
('Shan\'Li','Capital',750000,'ZON'),
("Bao'Ming",'Ciudad comercial',500000,'ZON');

-- Novariano (Se habla en Noverland, idioma oficial,
-- 95% de hablantes).
INSERT INTO CountryLanguage
VALUES ('NVL','Novariano','T',95);
-- Zionés (Se habla en Zionia, idioma oficial, 92% de hablantes).
INSERT INTO CountryLanguage
VALUES ('ZON','Zionés','T',92);

-- Aumentar la población de Villarrobledo
UPDATE City
SET Population = Population + 1500
WHERE Name = 'Villarrobledo';




