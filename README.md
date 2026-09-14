# Mouse Jiggler para macOS

Aplicacion nativa de macOS escrita en `SwiftUI` y `AppKit` que se instala como `.app`, vive en la barra de menu y mueve el cursor automaticamente en el intervalo que definas.

## Caracteristicas

- Intervalo configurable desde `0.5` hasta `3600` segundos.
- Control rapido desde un icono visible en la barra de menu y panel de control propio.
- Estado visible en la barra superior: `Activo` o `Inactivo`.
- Solicitud de permiso de Accesibilidad cuando hace falta.
- Icono propio para Finder y para la app instalada.
- Script de build que deja `.app`, `.zip` y `.dmg`.
- Menu de barra superior con acciones rapidas y acceso al panel.
- Opcion para iniciar movimiento al abrir la app.
- Opcion para abrir la app al iniciar sesion en macOS.

## Compilar

```bash
zsh Scripts/build_app.sh
```

Firma opcional:

```bash
APP_SIGN_IDENTITY="Developer ID Application: Tu Nombre" \
INSTALLER_SIGN_IDENTITY="Developer ID Installer: Tu Nombre" \
zsh Scripts/build_app.sh
```

Salida esperada:

- `build/MouseJiggler.app`
- `dist/MouseJiggler.app`
- `dist/MouseJiggler.zip`
- `dist/MouseJiggler.dmg`

## Instalar

1. Ejecuta `zsh Scripts/build_app.sh`.
2. Instala desde `dist/MouseJiggler.dmg` o abre `build/MouseJiggler.app`.
3. Al pulsar `Iniciar`, macOS pedira permiso en `Ajustes del Sistema > Privacidad y seguridad > Accesibilidad`.

Nota sobre el instalador:

- El `.pkg` se genera, pero para que macOS lo trate como instalador de distribucion sin advertencias necesitas una identidad `Developer ID Installer`.
- Si no firmas, el artefacto mas fiable para instalar en tu propia Mac sigue siendo `dist/MouseJiggler.app` o `dist/MouseJiggler.dmg`.

## Uso

- Haz clic en el estado `Activo` o `Inactivo` de la barra superior para abrir el menu.
- Desde ese menu puedes iniciar, detener, mover una vez y abrir el panel.
- Define el intervalo en segundos.
- Pulsa `Iniciar`.
- Usa `Abrir panel` si quieres ver la interfaz completa.
- Usa `Detener` para pausar el movimiento.
