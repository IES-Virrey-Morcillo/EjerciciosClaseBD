-- Obtén el nombre y correo electrónico de los clientes 
-- inactivos que tengan alguna película en alquiler sin devolver.
SELECT first_name, email
FROM customer 
WHERE active = 0
  AND customer_id in (SELECT DISTINCT customer_id 
					  FROM rental
					  WHERE return_date IS NULL);

-- Muestra el título, duración y clasificación por edad de las 
-- películas que hayan participado más de 10 actores.

SELECT title, length, rating
FROM film 
WHERE film_id IN (SELECT film_id
				  FROM film_actor
                  GROUP BY film_id
                  HAVING count(*) > 10);
                  
-- Muestra toda la información sobre las ciudades en las que no haya 
-- ninguna dirección.
SELECT *
FROM city
WHERE city_id NOT IN (SELECT DISTINCT city_id FROM address);

-- Muestra nombre, apellidos y correo electrónico de los clientes que han 
-- alquilado alguna vez AMERICAN CIRCUS en la tienda número 1 desde mayo
--  hasta junio de 2005.

SELECT first_name, last_name, email
FROM customer
WHERE customer_id IN (SELECT customer_id
					  FROM rental
                      WHERE rental_date BETWEEN "2005-05-01 00:00:00" AND "2005-06-30 23:59:59"
                       AND inventory_id IN (SELECT inventory_id
											 FROM inventory
                                             WHERE store_id = 1
                                               AND film_id IN (SELECT film_id
															   FROM film
                                                               WHERE title = "AMERICAN CIRCUS")));
                                                               
-- Inserta la película Titanic, estrenada el año 1997, con la descripción:

 -- “Jack (DiCaprio), un joven artista, gana en una partida de cartas un pasaje 
 -- para viajar a América en el Titanic, el transatlántico más grande y seguro 
 -- jamás construido. A bordo conoce a Rose (Kate Winslet), una joven de una 
 -- buena familia venida a menos que va a contraer un matrimonio de conveniencia con Cal (Billy Zane), un millonario engreído a quien sólo interesa el prestigioso apellido de su prometida.”

-- Originalmente en inglés, aunque esta versión está en italiano. Tiene una 
-- duración de 195 minutos, y una clasificación por edad de PG-13. La última 
-- actualización será la fecha y hora actual. Los campos no mencionados se insertarán con los valores por defecto.
INSERT INTO film (title, description, release_year, language_id, original_language_id,
                  length, rating, last_update)
VALUES ("Titanic", "Jack (DiCaprio), un joven artista, ...",
		1997, 2, 1, 195, "PG-13", now());
-- Se han comprado tres ejemplares de esta película, una se ha dejado en la 
-- tienda 1, y dos en la tienda 2. Refleja estos hechos en la tabla 
-- inventario.
INSERT INTO inventory (film_id, store_id) VALUES (1001,1),(1001,2),(1001,2);

-- Inserta dos actores para la película Titanic:
-- Leonardo Di Caprio
-- Kate Winslet
-- Escribe las sentencias que creas necesarias para realizar esto. 
-- Los campos no mencionados se insertarán con los valores por defecto.
-- Supón los identificadores que creas necesarios si no pudieras las 
-- sentencias en la máquina virtual.

INSERT INTO actor (first_name, last_name) VALUES ("Leonardo", "Di Caprio"),
												 ("Kate", "Winslet");
INSERT INTO film_actor (actor_id, film_id) VALUES (201,1001), (202,1001);

-- Da de alta un alquiler para el usuario José Manuel, para una de las películas
-- Titanic que hay en la tienda 2, desde el día de hoy, hasta dentro de 3 días.
-- Lo ha atendido Mike Hillyer. El resto de campos por defecto. 
-- Obtén los datos que necesites realizando las consultas previas que creas, 
-- es decir, ES UNA INSERCIÓN SENCILLA, no hay que hacer consultas en la propia
-- sentencia.

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (current_date(), 4583, 22, current_date()+3, 1);

-- Aumenta la cantidad (amount) de todos los pagos (payment) del cliente 
-- 4 realizados durante el día 2005-06-16 un 35%.
UPDATE payment
SET amount = amount * 1.35
WHERE customer_id = 4
  AND payment_date BETWEEN "2005-06-16 00:00:00" AND "2005-06-16 23:59:59";

-- Desactiva todos los clientes que vivan en el distrito de California o Texas.
UPDATE customer
SET active = 0
WHERE address_id IN (SELECT address_id 
					 FROM address 
                     WHERE district IN ("California","Texas"));

-- Actualiza el nombre de las ciudades del país llamado México, añadiendo al 
-- final de cada ciudad el número de caracteres que tiene el nombre de cada 
-- ciudad entre paréntesis. Por ejemplo: Hidalgo pasará a llamarse Hidalgo (7). 
-- Para saber el número de caracteres deberás usar la función length(cadena), 
-- la cual devuelve el número de caracteres directamente.
UPDATE city
SET city = CONCAT(city, " (", length(city),")")
WHERE country_id IN (SELECT country_id FROM country WHERE country = "México");


-- Disminuye el coste de reemplazo en un 10% a todas las películas que duren 
-- menos de 150 minutos y en las que participe la actriz RENEE TRACY o 
-- AL GARLAND

UPDATE film
SET replacement_cost = replacement_cost * 0.9
WHERE length < 150
  AND film_id IN (SELECT film_id
			      FROM film_actor 
                  WHERE actor_id IN (select actor_id 
								     FROM actor 
                                     WHERE first_name = "RENEE" 
                                       or first_name = "AL"));


-- Elimina las categorías que tengan asociadas las películas
-- con id entre 100 y 200, ambos incluidos.
DELETE FROM film_category
WHERE film_id BETWEEN 100 AND 200;

-- Elimina los pagos de menos de 5€ que no tengan asociado ningún alquiler.
DELETE FROM payment
WHERE amount < 5 AND rental_id IS NULL;

-- Elimina los inventarios de la tienda que gestiona Jon Stephens. Hazlo a través de subconsultas. 
-- ¿Qué habría que hacer previamente para que esta eliminación funcione? 
-- Hazlo y pega también la sentencia o sentencias (sin modificar la estructura de la base de datos).
DELETE FROM inventory
WHERE store_id IN (SELECT store_id FROM store
				   WHERE manager_staff_id IN (SELECT staff_id
											  FROM staff
                                              WHERE first_name = "Jon"
                                                AND last_name = "Stephens"));


-- Hemos contratado a nuestros mejores clientes. Estos son aquellos que han 
-- realizado pagos por un valor total mayor a 100€. Para darlos de alta como tal,
-- aprovecharemos parcialmente los datos que ya tenemos en la tabla cliente para 
-- insertarlos en la tabla de personal (staff): nombre, apellidos, dirección 
-- y tienda tal y como está en la tabla cliente; la fotografía nula y sin 
-- activar (0); para el email se unirá su nombre en minúsculas a la cadena 
-- “@virreyclub.es”; el usuario será las 3 primeras letras del nombre unidas a 
-- las 3 últimas letras del apellido; la contraseña será el sha1 del apellido.

-- Las funciones que podrías necesitar son: sha1(cadena), left(cadena), right(cadena), concat(cadena,cadena,…)

INSERT INTO staff (first_name,last_name, address_id, store_id,picture,active,
				   email, username, password) 
(SELECT first_name,last_name, address_id, store_id, null, 0,
		concat(lcase(first_name),"@virreyclub.es"),
        concat(left(first_name, 3),right(last_name,3)),
        sha1(last_name)
FROM customer
WHERE customer_id IN (SELECT customer_id 
					  FROM payment
					  GROUP BY customer_id
                      HAVING SUM(amount) > 200));

-- Queremos añadir como clientes al personal que está inactivo. Aprovecharemos 
-- estos campos tal y como están en la tabla de personal: nombre, apellidos 
-- y dirección. Todos serán clientes de la tienda 1. El email será su nombre y 
-- apellidos junto a "@gmail.com". Estarán activos. La fecha de creación será
-- la fecha/hora actual. 
INSERT INTO customer (first_name, last_name, address_id, store_id, email, active
					  ,create_date)
(SELECT first_name, last_name, address_id, 1, 
		CONCAT(first_name, last_name, "@gmail.com"),
        1,now()
FROM staff
WHERE active = 0);



