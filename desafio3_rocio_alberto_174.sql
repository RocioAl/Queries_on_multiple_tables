-- Desafío 3 - Consultas en Múltiples Tablas
-- Para este desafío debes crear una base de datos con las siguientes tablas.

-- Creación de una base de datos 
CREATE DATABASE desafio3_rocio_alberto_174;
-- Se conecta La base de datos creada.

-- 1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo
-- pedido. (1 Punto)

-- Creación de la tabla users

CREATE TABLE users(id SERIAL, email VARCHAR(50) NOT NULL, name VARCHAR NOT NULL, last_name VARCHAR NOT NULL, rol VARCHAR);

-- Ingresamos datos a la tabla users

INSERT INTO users(email, name, last_name, rol) VALUES 
('daniel@gmail.com', 'Daniel', 'Pacheco', 'administrador'),
('francisco@gmail.com', 'Francisco', 'Jacay', 'ingeniero'),
('pablo@gmail.com', 'Pablo', 'Ruiz', 'ingeniero'),
('alexis@gmail.com','Alexis', 'Huarac', 'ingeniero'),
('david@gmail.com', 'David', 'Cardenas', 'ingeniero');

-- Creación de la tabla posts

CREATE TABLE posts(
  id SERIAL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
 created_date TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_date TIMESTAMP NOT NULL DEFAULT NOW(),
  outstanding BOOLEAN NOT NULL DEFAULT FALSE,
  user_id BIGINT
);

-- Ingresamos datos a la tabla posts

INSERT INTO posts (title, content,created_date, updated_date, outstanding, user_id)
VALUES ('post1', 'contenido post1', '20/01/2023', '21/01/2023', true, 1),
('post2', 'contenido post2', '23/01/2023', '23/01/2023', true, 1),
('post3', 'contenido post3', '24/01/2023', '25/01/2023', true, 2),
('post4', 'contenido post4', '26/01/2023', '27/01/2023', false, 2),
('post5', 'contenido post5', '28/01/2023', '27/01/2023', false, null);

-- Creación de la tabla comments

CREATE TABLE comments(
  id SERIAL,
  content TEXT NOT NULL,
 created_date TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id BIGINT,
  post_id BIGINT
);
-- Ingresamos datos a la tabla comments

INSERT INTO comments (content,created_date, user_id,
post_id) VALUES 
('comentario 1', '28/01/2023', 1, 1),
('comentario 2', '28/01/2023', 2, 1),
('comentario 3', '29/01/2023', 3, 1),
('comentario 4', '29/01/2023', 1, 2);

-- 2. Cruza los datos de la tabla usuarios y posts mostrando las siguientes columnas, nombre e email del usuario junto al título y contenido del post. (1 Punto)

SELECT users.name, users.email, posts.title, posts.content FROM users INNER JOIN posts ON users.id = posts.user_id;
  name |     email      |    title    |        content
  ------+----------------+-------------+-----------------------
  Daniel | daniel@gmail.com  | post2     | contenido post2
  Daniel | daniel@gmail.com  | post1      | contenido post1
  Francisco | francisco@gmail.com | post4 | contenido post4
  Francisco | francisco@gmail.com | post3  | contenido post3


-- 3. Muestra el id, título y contenido de los posts de los administradores. El administrador puede ser cualquier id y debe ser seleccionado dinámicamente. (1 Punto)

SELECT posts.id, posts.title, posts, content FROM posts INNER JOIN users ON posts.user_id = users.id WHERE users.rol = 'administrador';
  id |  title  |                                      posts                                      |      content
  ----+---------+---------------------------------------------------------------------------------+-------------------
    1 | post1  | (1,post1,"contenido post1","2023-01-20 00:00:00","2023-01-21 00:00:00",t,1)  | contenido post1
    2 | post2 |(2,post2,"contenido post2","2023-01-23 00:00:00","2023-01-23 00:00:00",t,1)| contenido post2

-- 4. Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id
-- e email del usuario junto con la cantidad de posts de cada usuario.

SELECT COUNT(posts), users.id, users.id, users.email FROM posts RIGHT JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY users.id ASC;
  count | id | id |     email
  -------+----+----+----------------
      2 |  1 |  1 | daniel@gmail.com
      2 |  2 |  2 | francisco@gmail.com
      0 |  3 |  3 | pablo@gmail.com
      0 |  4 |  4 | alexis@gmail.com
      0 |  5 |  5 | david@gmail.com

-- 5. Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene
-- un único registro y muestra solo el email.

SELECT users.email FROM posts JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY COUNT(posts.id) DESC LIMIT 1;

      email
  ---------------
  daniel@gmail.com

-- 6. Muestra la fecha del último post de cada usuario. (1 Punto)

SELECT users.name, MAX(posts.created_date) FROM users INNER JOIN posts ON users.id = posts.user_id GROUP BY users.name;

  name |         max
  ------+---------------------
  Francisco | 2023-01-26 00:00:00
  Daniel | 2023-01-23 00:00:00

-- 7. Muestra el título y contenido del post (artículo) con más comentarios. (1 Punto)

SELECT posts.title, posts.content, COUNT(*) FROM posts INNER JOIN comments 
ON posts.id = comments.post_id GROUP BY posts.title, posts.content ORDER BY COUNT(*) DESC LIMIT 1;
  title  |     content      | count
  --------+------------------+-------
  post1 | contenido post1 |     3

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
-- de cada comentario asociado a los posts mostrados, junto con el email del usuario
-- que lo escribió. (1 Punto)

SELECT posts.title AS Title_post, posts.content AS content_post, comments.content AS content_comments, users.email
FROM posts LEFT JOIN comments ON posts.id = comments.post_id LEFT JOIN users ON comments.user_id = users.id;
  title_post  |     content_post      | content_comments |     email
  -------------+-----------------------+------------------+----------------
  post1      | contenido post1      | comentario 1     | daniel@gmail.com
  post1      | contenido post1      | comentario 2     | francisco@gmail.com
  post1      | contenido post1      | comentario 3     | pablo@gmail.com
  post2     | contenido post2     | comentario 4     | daniel@gmail.com
  post5      | contenido post5      |                  |
  post4 | contenido post4 |                  |
  post3  | contenido post3  |                  |

-- 9. Muestra el contenido del último comentario de cada usuario. (1 Punto)

SELECT comments.user_id, comments.content FROM comments
INNER JOIN (SELECT max(comments.id) AS last_id FROM comments GROUP BY user_id) AS dt_last_reg
ON comments.id = dt_last_reg.last_id ORDER BY comments.user_id;
  user_id |   content
  ---------+--------------
        1 | comentario 4
        2 | comentario 2
        3 | comentario 3

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario. (1 Punto)
--  Primera forma 

SELECT users.email FROM users LEFT JOIN comments ON users.id = comments.user_id WHERE comments.content IS NULL;
      email
  ---------------
  david@gmail.com
  alexis@gmail.com

-- Segunda forma
SELECT users.email FROM users LEFT JOIN comments ON users.id = comments.user_id GROUP BY users.email, comments.content HAVING comments.content IS NULL;
      email
  ---------------
  alexis@gmail.com
  david@gmail.com