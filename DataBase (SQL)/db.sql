CREATE TABLE IF NOT EXISTS Crupier (
    id_crupier INT PRIMARY KEY,
    nombre_crupier VARCHAR(100) NOT NULL,
    experiencia_anios INT NOT NULL,
    horas_turno INT NOT NULL,
    nivel_satisfaccion DECIMAL(3,2)
);

CREATE TABLE IF NOT EXISTS Games (
    id_game INT PRIMARY KEY,
    duracion_juego INT NOT NULL,
    apuesta_min DECIMAL(10,2) NOT NULL,
    id_elemento INT
);

CREATE TABLE IF NOT EXISTS Crupier_Game (
    id_crupier INT,
    id_game INT,
    PRIMARY KEY (id_crupier, id_game)
);

CREATE TABLE IF NOT EXISTS Caja (
    id_caja INT PRIMARY KEY,
    balance_disponible DECIMAL(15,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Users (
    id_user INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    cantidad_dinero DECIMAL(15,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS User_Caja (
    id_user INT,
    id_caja INT,
    horas_activas INT NOT NULL,
    prestamos_caja DECIMAL(15,2),
    plazo_pago_caja INT,
    PRIMARY KEY (id_user, id_caja)
);

CREATE TABLE IF NOT EXISTS Estado_Usuario (
    id_evento INT,
    id_user INT,
    estado_trampa BOOLEAN NOT NULL,
    fecha_actualizacion DATE,
    PRIMARY KEY (id_evento, id_user)
);

CREATE TABLE IF NOT EXISTS Estadistica_Juego (
    id_game INT,
    id_user INT,
    estadisticas TEXT,
    PRIMARY KEY (id_game, id_user)
);

CREATE TABLE IF NOT EXISTS Elementos (
    id_elemento INT PRIMARY KEY,
    tipo_recurso VARCHAR(50) NOT NULL,
    cantidad INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Sala (
    id_sala INT PRIMARY KEY,
    numero_sala INT NOT NULL,
    capacidad INT NOT NULL,
    id_game INT
);

CREATE TABLE IF NOT EXISTS Eventos (
    id_evento INT PRIMARY KEY,
    nombre_evento VARCHAR(100) NOT NULL,
    fecha_evento TIMESTAMP NOT NULL,
    id_sala INT,
    id_crupier INT,
    id_user INT
);

ALTER TABLE Crupier_Game
ADD CONSTRAINT fk_crupier
FOREIGN KEY (id_crupier) REFERENCES Crupier(id_crupier);

ALTER TABLE Crupier_Game
ADD CONSTRAINT fk_game
FOREIGN KEY (id_game) REFERENCES Games(id_game);

ALTER TABLE Games
ADD CONSTRAINT fk_elemento
FOREIGN KEY (id_elemento) REFERENCES Elementos(id_elemento);

ALTER TABLE User_Caja
ADD CONSTRAINT fk_user
FOREIGN KEY (id_user) REFERENCES Users(id_user);

ALTER TABLE User_Caja
ADD CONSTRAINT fk_caja
FOREIGN KEY (id_caja) REFERENCES Caja(id_caja);

ALTER TABLE Estado_Usuario
ADD CONSTRAINT fk_estado_user
FOREIGN KEY (id_user) REFERENCES Users(id_user);

ALTER TABLE Estadistica_Juego
ADD CONSTRAINT fk_game_stat
FOREIGN KEY (id_game) REFERENCES Games(id_game);

ALTER TABLE Estadistica_Juego
ADD CONSTRAINT fk_user_stat
FOREIGN KEY (id_user) REFERENCES Users(id_user);

ALTER TABLE Sala
ADD CONSTRAINT fk_game_sala
FOREIGN KEY (id_game) REFERENCES Games(id_game);

ALTER TABLE Eventos
ADD CONSTRAINT fk_sala
FOREIGN KEY (id_sala) REFERENCES Sala(id_sala);

ALTER TABLE Eventos
ADD CONSTRAINT fk_crupier_evento
FOREIGN KEY (id_crupier) REFERENCES Crupier(id_crupier);

ALTER TABLE Eventos
ADD CONSTRAINT fk_user_evento
FOREIGN KEY (id_user) REFERENCES Users(id_user);


INSERT INTO Crupier (id_crupier, nombre_crupier, experiencia_anios, horas_turno, nivel_satisfaccion)
VALUES (1, 'Juan Pérez', 5, 8, 4.5),
       (2, 'María Gómez', 3, 6, 4.0),
       (3, 'Carlos López', 7, 10, 4.8);

INSERT INTO Elementos (id_elemento, tipo_recurso, cantidad)
VALUES (1, 'Dados', 50),
       (2, 'Cartas', 200),
       (3, 'Ruleta', 10);

INSERT INTO Games (id_game, duracion_juego, apuesta_min, id_elemento)
VALUES (1, 30, 5.00, 1),
       (2, 45, 10.00, 2),
       (3, 60, 15.00, 3);

INSERT INTO Caja (id_caja, balance_disponible)
VALUES (1, 10000.00),
       (2, 15000.00);

INSERT INTO Users (id_user, nombre, email, cantidad_dinero)
VALUES (1, 'Pedro Sánchez', 'pedro@example.com', 1000.00),
       (2, 'Lucía Fernández', 'lucia@example.com', 2000.00),
       (3, 'José Martínez', 'jose@example.com', 1500.00);

INSERT INTO User_Caja (id_user, id_caja, horas_activas, prestamos_caja, plazo_pago_caja)
VALUES (1, 1, 20, 500.00, 30),
       (2, 2, 15, 300.00, 15);

INSERT INTO Estado_Usuario (id_evento, id_user, estado_trampa, fecha_actualizacion)
VALUES (1, 1, FALSE, '2024-10-01'),
       (2, 2, TRUE, '2024-10-15');

INSERT INTO Estadistica_Juego (id_game, id_user, estadisticas)
VALUES (1, 1, 'Ganó 2 veces, perdió 1 vez'),
       (2, 2, 'Ganó 1 vez, perdió 3 veces');

INSERT INTO Sala (id_sala, numero_sala, capacidad, id_game)
VALUES (1, 101, 10, 1),
       (2, 102, 15, 2);

INSERT INTO Eventos (id_evento, nombre_evento, fecha_evento, id_sala, id_crupier, id_user)
VALUES (1, 'Torneo de Dados', '2024-11-01 19:00:00', 1, 1, 1),
       (2, 'Noche de Póker', '2024-11-05 20:00:00', 2, 2, 2);