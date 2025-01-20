CREATE OR REPLACE FUNCTION ObtenerEventosFuturos()
RETURNS TABLE(id_evento INT, nombre_evento VARCHAR, fecha_evento TIMESTAMP, id_sala INT, id_crupier INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT Eventos.id_evento, Eventos.nombre_evento, Eventos
    .fecha_evento, Eventos.id_sala, Eventos.id_crupier
    FROM Eventos
    WHERE Eventos.fecha_evento > CURRENT_TIMESTAMP;
END;
$$;


CREATE OR REPLACE FUNCTION ObtenerProximoEvento()
RETURNS TABLE(id_evento INT, nombre_evento VARCHAR, fecha_evento TIMESTAMP, id_sala INT, id_crupier INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Eventos
    WHERE Eventos.fecha_evento > CURRENT_TIMESTAMP
    LIMIT 1;
END;
$$;

CREATE OR REPLACE FUNCTION ObtenerApuestaMIN (
    f_id_game INT
) RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    f_ApuestaMIN DECIMAL(10,2);
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM Games
        WHERE id_game = f_id_game
    ) THEN
        RAISE EXCEPTION 'El juego con ID % no existe, ingrse una ID valida', f_id_game;
    END IF;

    SELECT apuesta_min
    INTO f_ApuestaMIN
    FROM Games
    WHERE id_game = f_id_game;

    RETURN f_ApuestaMIN;
END;
$$;

CREATE OR REPLACE FUNCTION ObtenerDuracionJuego(
    f_id_game INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    f_duracion INT;
BEGIN
   
    IF NOT EXISTS (
        SELECT 1 FROM Games WHERE id_game = f_id_game
    ) THEN
        RAISE EXCEPTION 'El juego con ID % no existe.', f_id_game;
    END IF;

    SELECT duracion_juego
    INTO f_duracion
    FROM Games
    WHERE id_game = f_id_game;

    RETURN f_duracion;
END;
$$;

CREATE OR REPLACE PROCEDURE editNombreUser (
    p_id_user INT, 
    nuevoNombre VARCHAR(17)
) 
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE users
    SET nombre = nuevoNombre
    WHERE id_user = p_id_user;
END;
$$;

CREATE OR REPLACE PROCEDURE nuevoUsuario (
    p_id_user INT, 
    p_nombre VARCHAR(100), 
    p_email VARCHAR(100), 
    p_cantidad_dinero DECIMAL(15,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Users (id_user, nombre, email, cantidad_dinero)
    VALUES (p_id_user, p_nombre, p_email, p_cantidad_dinero);
END;
$$;



CREATE OR REPLACE PROCEDURE agregarEvento (
    p_id_evento INT, 
    p_nombre_evento VARCHAR(100), 
    p_fecha_evento DATE, 
    p_id_sala INT, 
    p_id_crupier INT 
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Eventos (id_evento, nombre_evento, fecha_evento, id_sala, id_crupier)
    VALUES (p_id_evento, p_nombre_evento, p_fecha_evento, p_id_sala, p_id_crupier);
END;
$$;

CREATE OR REPLACE PROCEDURE cambiarFechaEvento (
    p_id_evento INT, 
    p_nueva_fecha DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Eventos
    SET fecha_evento = p_nueva_fecha
    WHERE id_evento = p_id_evento;
END;
$$;

CREATE OR REPLACE FUNCTION BalanceTotal()
RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    total_balance DECIMAL(15,2);
BEGIN

    SELECT COALESCE(SUM(balance_disponible), 0)
    INTO total_balance
    FROM Caja;

    RETURN total_balance;
END;
$$;

CREATE OR REPLACE FUNCTION BalanceCaja(
    f_id_caja INT
) RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    balance DECIMAL(15,2);
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM Caja
        WHERE id_caja = f_id_caja
    ) THEN
        RAISE EXCEPTION 'La caja con ID % no existe.', f_id_caja;
    END IF;

    SELECT balance_disponible
    INTO balance
    FROM Caja
    WHERE id_caja = f_id_caja;

    RETURN balance;
END;
$$;

CREATE OR REPLACE FUNCTION UsuariosVetados()
RETURNS TABLE(id_user INT)
LANGUAGE plpgsql
AS $$
DECLARE
    cantidad_vetados INT;
BEGIN

    SELECT COUNT(*)
    INTO cantidad_vetados
    FROM Estado_Usuario
    WHERE estado_trampa = TRUE;

    RAISE NOTICE 'La cantidad de usuarios vetados es: %', cantidad_vetados;

    RETURN QUERY
    SELECT Estado_Usuario.id_user
    FROM Estado_Usuario
    WHERE estado_trampa = TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION ObtenerCantidadDineroUsuario(
    p_id_user INT
)
RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    cant_dinero DECIMAL(15,2);
BEGIN
 
    IF NOT EXISTS (
        SELECT 1 FROM Users WHERE users.id_user = p_id_user
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_user;
    END IF;

    SELECT cantidad_dinero
    INTO cant_dinero
    FROM Users
    WHERE users.id_user = p_id_user;

    RETURN cant_dinero;
END;
$$;

CREATE OR REPLACE FUNCTION HorasActivas()
RETURNS TABLE(id_user INT, horas_totales BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT user_caja.id_user, SUM(horas_activas) AS horas_totales
    FROM User_Caja
    GROUP BY User_Caja.id_user
    ORDER BY horas_totales DESC;
END;
$$;

CREATE OR REPLACE FUNCTION ObtenerHorasActivasPorUsuarioID(
    p_id_user INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    horas_totales INT;
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM Users WHERE users.id_user = p_id_user
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_user;
    END IF;

    SELECT SUM(horas_activas) INTO horas_totales
    FROM User_Caja
    WHERE User_Caja.id_user = p_id_user;

 
    IF horas_totales IS NULL THEN
        RETURN 0;
    END IF;

    RETURN horas_totales;
END;
$$;

ALTER TABLE Eventos
DROP COLUMN id_user;

CREATE TABLE IF NOT EXISTS Pertenece_Evento (
    id_evento INT,
    id_user INT,
    PRIMARY KEY (id_evento, id_user),
    CONSTRAINT fk_evento
        FOREIGN KEY (id_evento)
        REFERENCES Eventos(id_evento)
        ON DELETE CASCADE,
    CONSTRAINT fk_usuario
        FOREIGN KEY (id_user)
        REFERENCES Users(id_user)
        ON DELETE CASCADE
);



INSERT INTO Pertenece_Evento (id_evento, id_user)
VALUES (1, 1),
       (1, 2),
       (2, 3);


SELECT BalanceTotal();

SELECT BalanceCaja(2);

SELECT * FROM UsuariosVetados();

SELECT ObtenerCantidadDineroUsuario(1);

SELECT * FROM HorasActivas();

SELECT ObtenerHorasActivasPorUsuarioID(1);

CALL nuevoUsuario(9, 'Ana Pérez', 'ana@example.com', 2500.00);

CALL editNombreUser(1, 'Juan Pérez Actualizado');

CALL agregarEvento(9, 'Torneo de Ruleta', '2024-12-01', 1, 2, 1);

CALL cambiarFechaEvento(1, '2025-12-01');

SELECT * FROM ObtenerEventosFuturos();

SELECT * FROM ObtenerProximoEvento();

SELECT ObtenerApuestaMIN(1);

SELECT ObtenerDuracionJuego(1);
