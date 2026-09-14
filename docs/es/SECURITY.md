# Política de seguridad

[Read in English](../../SECURITY.md)

Mouse Jiggler funciona localmente y no realiza solicitudes de red de forma intencional. Aun así, son bienvenidos los reportes de seguridad, especialmente si involucran permisos de Accesibilidad, firma de código, empaquetado o inicio de sesión.

## Versiones soportadas

| Versión | Soporte |
| --- | --- |
| Última versión de la rama `main` | Sí |
| Última versión etiquetada | Sí |
| Versiones anteriores | Mejor esfuerzo |

## Reportar una vulnerabilidad

No abras un issue público para una posible vulnerabilidad.

1. Abre la pestaña **Security** del repositorio.
2. Selecciona **Report a vulnerability** para crear un aviso privado.
3. Incluye la versión afectada, versión de macOS, impacto, pasos de reproducción y cualquier mitigación sugerida.

Si los reportes privados todavía no están habilitados, contacta al mantenedor mediante el canal publicado en el [perfil de GitHub de Juan Eduardo Vargas](https://github.com/juaneduardovargas). No publiques información sensible en un issue.

El mantenedor hará lo posible por confirmar el reporte en un plazo de siete días, compartir avances y coordinar la divulgación después de disponer de una solución.

## Expectativas de seguridad

- Nunca incluyas certificados de Apple, claves privadas, credenciales de notarización ni exportaciones del llavero.
- Trata los artefactos sin firma o con firma ad-hoc como builds de desarrollo.
- Verifica los artefactos antes de publicar una versión.
- Mantén el uso de Accesibilidad limitado al movimiento del cursor descrito por el proyecto.

La investigación de buena fe que evite violaciones de privacidad, pérdida de datos e interrupciones es bienvenida.
