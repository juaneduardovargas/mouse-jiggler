# Contribuir a Mouse Jiggler

Gracias por ayudar a mejorar Mouse Jiggler. Son bienvenidas las contribuciones de código, documentación, traducciones, pruebas y clasificación de issues.

[Read in English](../../CONTRIBUTING.md)

## Antes de comenzar

- Lee el [Código de conducta](CODE_OF_CONDUCT.md).
- Busca issues existentes antes de crear uno nuevo.
- Usa el formulario bilingüe de errores o funcionalidades cuando sea posible.
- Mantén los cambios enfocados. Las modificaciones grandes de comportamiento deben discutirse primero en un issue.

## Entorno de desarrollo

Necesitas macOS 13 o superior y Xcode Command Line Tools.

```bash
git clone https://github.com/juaneduardovargas/mouse-jiggler.git
cd mouse-jiggler
zsh Scripts/validate_localizations.sh
zsh Scripts/build_app.sh
open build/MouseJiggler.app
```

La app necesita permiso de Accesibilidad para probar el movimiento del cursor. La compilación y la validación de traducciones no requieren ese permiso.

## Convenciones del proyecto

- Usa Swift y los frameworks nativos de Apple que ya están presentes.
- No dejes cadenas visibles para el usuario dentro del código Swift. Agrégalas a ambos archivos de traducción.
- Usa claves semánticas agrupadas por funcionalidad, como `menu.start` o `permission.required`.
- Agrega comentarios DocC a tipos o comportamientos que no sean evidentes.
- Prefiere cambios pequeños y fáciles de revisar; evita formatear archivos no relacionados.
- No incluyas `build/`, `dist/`, credenciales, certificados ni material de aprovisionamiento.

## Agregar o modificar traducciones

Actualiza ambos archivos:

- `Resources/en.lproj/Localizable.strings`
- `Resources/es.lproj/Localizable.strings`

Después ejecuta:

```bash
zsh Scripts/validate_localizations.sh
```

El inglés es el idioma de desarrollo y respaldo. Conserva marcadores de formato como `%@` y `%d` en todas las traducciones.

## Verificación

Antes de abrir un pull request, ejecuta:

```bash
zsh Scripts/validate_localizations.sh
zsh Scripts/build_app.sh
codesign --verify --deep --strict build/MouseJiggler.app
git diff --check
```

Para cambios visuales, prueba la app en inglés y español e incluye capturas actualizadas cuando la presentación cambie de forma importante.

## Pull requests

Un buen pull request:

- Explica el problema y la solución elegida.
- Enlaza el issue relacionado cuando exista.
- Describe las pruebas manuales realizadas.
- Actualiza documentación y traducciones cuando sea necesario.
- Mantiene los artefactos generados fuera del commit.

Al contribuir, aceptas que tu aporte se publique bajo la [Licencia MIT](../../LICENSE).
