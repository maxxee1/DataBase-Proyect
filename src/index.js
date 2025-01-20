import express from 'express';
import { engine } from 'express-handlebars';
import { sql } from './db.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.engine(
  'handlebars',
  engine({
    defaultLayout: 'main', 
  }),
);
app.set('view engine', 'handlebars');
app.set('views', './src/views'); 

app.use(express.static('public'));

// Rutas de la aplicación
app.get('/', (req, res) => {
  res.render('home', { title: 'Tienda INSIDE' }); 
});


app.get('/infoCas', async (req, res) => {
  try {
    const resultBalance = await sql`SELECT BalanceTotal() AS total_balance`;
    const totalBalance = resultBalance[0].total_balance;

    const resultVetados = await sql`SELECT * FROM UsuariosVetados()`;
    const usuariosVetados = resultVetados.map(row => row.id_user);
    const cantidadVetados = usuariosVetados.length;

    const { id_caja, id_user, id_user_activas } = req.query;

    let balanceCaja = null;
    let errorBalanceCaja = null;

    if (id_caja) {
      try {
        const resultCaja =
          await sql`SELECT BalanceCaja(${id_caja}) AS balance_caja`;
        balanceCaja = resultCaja[0].balance_caja;
      } catch (err) {
        errorBalanceCaja =
          'Error al obtener el balance de la caja o la caja no existe.';
      }
    }

    let cantidadDineroUsuario = null;
    let errorCantidadDineroUsuario = null;

    if (id_user) {
      try {
        const resultUsuario =
          await sql`SELECT ObtenerCantidadDineroUsuario(${id_user}) AS cantidad_dinero_usuario`;
        cantidadDineroUsuario = resultUsuario[0].cantidad_dinero_usuario;
      } catch (err) {
        errorCantidadDineroUsuario =
          'Error al obtener la cantidad de dinero del usuario o el usuario no existe.';
      }
    }

    let horasActivasUsuario = null;
    let errorHorasActivasUsuario = null;

    if (id_user_activas) {
      try {
        const resultHorasActivas = await sql`
          SELECT horas_totales FROM HorasActivas() WHERE id_user = ${id_user_activas}
        `;
        if (resultHorasActivas.length > 0) {
          horasActivasUsuario = resultHorasActivas[0].horas_totales;
        } else {
          errorHorasActivasUsuario =
            'El usuario con este ID no tiene horas activas registradas.';
        }
      } catch (err) {
        errorHorasActivasUsuario =
          'Error al obtener las horas activas del usuario o el usuario no existe.';
      }
    }

    const resultHorasActivas = await sql`SELECT * FROM HorasActivas()`;
    const horasActivas = resultHorasActivas.map(row => ({
      id_user: row.id_user,
      horas_totales: row.horas_totales,
    }));

    res.render('infoCas', {
      title: 'Información del Casino',
      totalBalance,
      cantidadVetados,
      usuariosVetados,
      balanceCaja,
      errorBalanceCaja,
      cantidadDineroUsuario,
      errorCantidadDineroUsuario,
      horasActivasUsuario,
      errorHorasActivasUsuario,
      horasActivas,
    });
  } catch (err) {
    console.error('Error al obtener la información:', err);
    res.status(500).send('Error al obtener la información');
  }
});



app.get('/infoGam', async (req, res) => {
  try {
    const { id_apuesta, id_duracion } = req.query;

    // Consultas generales
    const eventosFuturos = await sql`SELECT * FROM ObtenerEventosFuturos()`;
    const proximoEvento = await sql`SELECT * FROM ObtenerProximoEvento()`;

    let apuestaMIN = null;
    let duracionJuego = null;
    let errorApuesta = null;
    let errorDuracion = null;

    // Consulta de apuesta mínima si se proporciona id_apuesta
    if (id_apuesta) {
      try {
        const apuestaMINResult =
          await sql`SELECT ObtenerApuestaMIN(${id_apuesta})`;
        apuestaMIN = apuestaMINResult[0]?.obtenerapuestamin || null;

        if (!apuestaMIN) {
          errorApuesta = 'ID de juego para apuesta inválido.';
        }
      } catch (dbErr) {
        console.error('Error al obtener la apuesta mínima:', dbErr);
        errorApuesta = 'Error al obtener la apuesta mínima.';
      }
    }

    // Consulta de duración del juego si se proporciona id_duracion
    if (id_duracion) {
      try {
        const duracionJuegoResult =
          await sql`SELECT ObtenerDuracionJuego(${id_duracion})`;
        duracionJuego = duracionJuegoResult[0]?.obtenerduracionjuego || null;

        if (!duracionJuego) {
          errorDuracion = 'ID de juego para duración inválido.';
        }
      } catch (dbErr) {
        console.error('Error al obtener la duración del juego:', dbErr);
        errorDuracion = 'Error al obtener la duración del juego.';
      }
    }

    // Renderizar la página con los datos obtenidos
    res.render('infoGam', {
      title: 'Eventos Futuros y Datos del Juego',
      eventosFuturos,
      proximoEvento: proximoEvento.length > 0 ? proximoEvento[0] : null,
      apuestaMIN,
      duracionJuego,
      errorApuesta,
      errorDuracion,
    });
  } catch (err) {
    console.error('Error al cargar la página:', err);
    res.status(500).send('Error al cargar la página.');
  }
});


app.get('/edit', async (req, res) => {
  try {
    const { id_User, nuevoNombre } = req.query;

    let mensajeError = null;
    let mensajeExito = null;

    // Validación de los parámetros
    if (!id_User || !nuevoNombre) {
      mensajeError = 'Se debe proporcionar un id_User y un nuevoNombre.';
      return res.render('edit', { mensajeError });
    }

    try {
      // Llamada al procedimiento almacenado para editar el nombre del usuario
      await sql`
        CALL editNombreUser(${id_User}, ${nuevoNombre});
      `;
      mensajeExito = 'Nombre de usuario actualizado correctamente.';
      res.render('edit', { mensajeExito });
    } catch (dbErr) {
      console.error('Error al actualizar el nombre del crupier:', dbErr);
      mensajeError =
        'Hubo un error al intentar actualizar el nombre del usuario.';
      res.render('edit', { mensajeError });
    }
  } catch (err) {
    console.error('Error al procesar la solicitud de edición:', err);
    res.status(500).send('Hubo un error al procesar la solicitud.');
  }
});

app.get('/nuevoUsuario', async (req, res) => {
  try {
    const { id_user, nombre, email, cantidad_dinero } = req.query;

    let mensajeErrorNuevoUsuario = null;
    let mensajeExitoNuevoUsuario = null;

    if (!id_user || !nombre || !email || !cantidad_dinero) {
      mensajeErrorNuevoUsuario = 'Todos los campos son requeridos.';
      return res.render('edit', { mensajeErrorNuevoUsuario });
    }

    try {
      await sql`
        CALL nuevoUsuario(${id_user}, ${nombre}, ${email}, ${cantidad_dinero});
      `;
      mensajeExitoNuevoUsuario = 'Usuario agregado correctamente.';
      res.render('edit', { mensajeExitoNuevoUsuario });
    } catch (dbErr) {
      console.error('Error al agregar el nuevo usuario:', dbErr);
      mensajeErrorNuevoUsuario =
        'Hubo un error al intentar agregar el usuario.';
      res.render('edit', { mensajeErrorNuevoUsuario });
    }
  } catch (err) {
    console.error('Error al procesar la solicitud de nuevo usuario:', err);
    res.status(500).send('Hubo un error al procesar la solicitud.');
  }
});


app.get('/agregarEvento', async (req, res) => {
  try {
    const {
      id_evento,
      nombre_evento,
      fecha_evento,
      id_sala,
      id_crupier
    } = req.query;

    let mensajeErrorAgregarEvento = null;
    let mensajeExitoAgregarEvento = null;

    if (
      !id_evento ||
      !nombre_evento ||
      !fecha_evento ||
      !id_sala ||
      !id_crupier 
    ) {
      mensajeErrorAgregarEvento = 'Todos los campos son requeridos.';
      return res.render('edit', { mensajeErrorAgregarEvento });
    }

    try {
      await sql`
        CALL agregarEvento(${id_evento}, ${nombre_evento}, ${fecha_evento}, ${id_sala}, ${id_crupier});
      `;
      mensajeExitoAgregarEvento = 'Evento agregado correctamente.';
      res.render('edit', { mensajeExitoAgregarEvento });
    } catch (dbErr) {
      console.error('Error al agregar el evento:', dbErr);
      mensajeErrorAgregarEvento =
        'Hubo un error al intentar agregar el evento.';
      res.render('edit', { mensajeErrorAgregarEvento });
    }
  } catch (err) {
    console.error('Error al procesar la solicitud de agregar evento:', err);
    res.status(500).send('Hubo un error al procesar la solicitud.');
  }
});

app.get('/cambiarFechaEvento', async (req, res) => {
  try {
    const { id_evento, nueva_fecha } = req.query;

    let mensajeErrorCambiarFecha = null;
    let mensajeExitoCambiarFecha = null;

    // Validar que los parámetros sean correctos
    if (!id_evento || !nueva_fecha) {
      mensajeErrorCambiarFecha = 'Todos los campos son requeridos.';
      return res.render('edit', { mensajeErrorCambiarFecha });
    }

    try {
      // Llamar a la función cambiarFechaEvento en la base de datos
      await sql`
        CALL cambiarFechaEvento(${id_evento}, ${nueva_fecha});
      `;

      mensajeExitoCambiarFecha = 'Fecha del evento actualizada correctamente.';
      res.render('edit', { mensajeExitoCambiarFecha });
    } catch (dbErr) {
      console.error('Error al cambiar la fecha del evento:', dbErr);
      mensajeErrorCambiarFecha =
        'Hubo un error al intentar cambiar la fecha del evento.';
      res.render('edit', { mensajeErrorCambiarFecha });
    }
  } catch (err) {
    console.error('Error al procesar la solicitud de cambiar fecha:', err);
    res.status(500).send('Hubo un error al procesar la solicitud.');
  }
});




app.listen(PORT, () => {
  console.log(`Aplicación corriendo en http://localhost:${PORT}`);
});
