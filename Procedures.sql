/* -------------------- Informacion Casino -------------------- */

-- Balance todas las cajas
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

-- Balance de una caja por ID
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

-- Listar usuarios vetados
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

--Obtener dinero por ID
CREATE OR REPLACE FUNCTION ObtenerCantidadDineroUsuario(
    p_id_user INT
)
RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    cantidad_dinero DECIMAL(15,2);
BEGIN
 
    IF NOT EXISTS (
        SELECT 1 FROM Users WHERE id_user = p_id_user
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_user;
    END IF;

    SELECT cantidad_dinero
    INTO cantidad_dinero
    FROM Users
    WHERE id_user = p_id_user;

    RETURN cantidad_dinero;
END;
$$;

-- horas de todos los usuarios
CREATE OR REPLACE FUNCTION ObtenerHorasActivasPorUsuario()
RETURNS TABLE(id_user INT, horas_totales INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id_user, SUM(horas_activas) AS horas_totales
    FROM User_Caja
    GROUP BY id_user
    ORDER BY horas_totales DESC;
END;
$$;

-- horas de usuario por id_user
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
        SELECT 1 FROM Users WHERE id_user = p_id_user
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_user;
    END IF;

    SELECT SUM(horas_activas) INTO horas_totales
    FROM User_Caja
    WHERE id_user = p_id_user;

 
    IF horas_totales IS NULL THEN
        RETURN 0;
    END IF;

    RETURN horas_totales;
END;
$$;

--evento mas efectivo
CREATE OR REPLACE FUNCTION ObtenerEventoConMasJugadoresNuevos()
RETURNS TABLE(id_evento INT, jugadores_nuevos INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT Eventos.id_evento, COUNT(uc.id_user) AS jugadores_nuevos
    FROM User_Caja uc
    JOIN Eventos e ON uc.id_user = e.id_user
    WHERE uc.horas_activas = (SELECT MIN(horas_activas) FROM User_Caja)
    GROUP BY e.id_evento
    ORDER BY jugadores_nuevos DESC
    LIMIT 1;
END;
$$;


/* -------------------- Informacion Juego -------------------- */

-- Todos los eventos futuros
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

-- Proximo evento
CREATE OR REPLACE FUNCTION ObtenerProximoEvento()
RETURNS TABLE(id_evento INT, nombre_evento VARCHAR, fecha_evento TIMESTAMP, id_sala INT, id_crupier INT, id_user INT)
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

-- Apuesta minima de un juego
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
        RAISE EXCEPTION 'El juego con ID % no existe.', f_id_game;
    END IF;

    SELECT apuesta_min
    INTO f_ApuestaMIN
    FROM Games
    WHERE id_game = f_id_game;

    RETURN f_ApuestaMIN;
END;
$$;

-- Obtener duracion
CREATE OR REPLACE FUNCTION ObtenerDuracionJuego(
    f_id_game INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    duracion INT;
BEGIN
   
    IF NOT EXISTS (
        SELECT 1 FROM Games WHERE id_game = p_id_game
    ) THEN
        RAISE EXCEPTION 'El juego con ID % no existe.', p_id_game;
    END IF;

    SELECT duracion_juego
    INTO duracion
    FROM Games
    WHERE id_game = p_id_game;

    RETURN duracion;
END;
$$;

-- Evento mas exitoso
CREATE OR REPLACE FUNCTION ObtenerEventoConMasParticipantes()
RETURNS TABLE(id_evento INT, participantes INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id_evento, COUNT(id_user) AS participantes
    FROM Eventos
    GROUP BY id_evento
    ORDER BY participantes DESC
    LIMIT 1;
END;
$$;

-- participantes por evento
CREATE OR REPLACE FUNCTION ObtenerParticipantesPorEvento(
    p_id_evento INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    cantidad_participantes INT;
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM Eventos WHERE id_evento = p_id_evento
    ) THEN
        RAISE EXCEPTION 'El evento con ID % no existe.', p_id_evento;
    END IF;

    SELECT COUNT(id_user) INTO cantidad_participantes
    FROM Eventos
    WHERE id_evento = p_id_evento;

    RETURN cantidad_participantes;
END;
$$;

/* -------------------- Informacion Juego -------------------- */
