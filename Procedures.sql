/*-------------------------- Funciones --------------------------*/

--Obtener la apuesta minima por id_game
CREATE OR REPLACE FUNCTION ObtenerApuestaMIN (
    f_id_game INT
) RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    f_ApuestaMIN DECIMAL(10,2);
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Games
        WHERE id_game = f_id_game
    ) THEN

        SELECT apuesta_min
        INTO f_ApuestaMIN
        FROM Games
        WHERE id_game = f_id_game;
        
        RETURN f_ApuestaMIN;
    ELSE
        RAISE EXCEPTION 'El juego con ID % no existe.', f_id_game;
    END IF;
END;
$$;