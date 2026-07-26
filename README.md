# kosmik2001 overlay

[EN] Gentoo overlay for Fusion Icon 2 — system tray for switching Compiz window managers.
[RU] Gentoo оверлей для Fusion Icon 2 — системный трей для переключения оконных менеджеров Compiz.

## Add overlay / Добавление оверлея

### Method 1: eselect repository / Способ 1: eselect repository

```bash
sudo emerge app-eselect/eselect-repository
sudo eselect repository enable kosmik2001 https://github.com/KosmiK2001/fusion-icon-2-overlay.git
sudo eselect repository sync kosmik2001
```

### Method 2: Manual / Способ 2: Вручную

```bash
sudo mkdir -p /var/db/repos/kosmik2001
sudo git clone https://github.com/KosmiK2001/fusion-icon-2-overlay.git /var/db/repos/kosmik2001
```

## Install / Установка

```bash
sudo emerge --sync kosmik2001
sudo emerge --ask x11-misc/fusion-icon2
```

## USE flags / USE-флаги

| Flag | Default | Description (EN) | Описание (RU) |
|------|---------|------------------|---------------|
| `+file` | Yes | Store settings in plain text config file (~/.config/fusion-icon2/config) | Хранение настроек в текстовом файле |
| `-gsettings` | No | Store settings using GSettings/dconf (mutually exclusive with file) | Хранение настроек через GSettings/dconf (взаимоисключающе с file) |
| `+upx` | Yes | Compress binary with UPX for smaller size | Сжатие бинарника UPX для уменьшения размера |

## Dependencies / Зависимости

- `dev-cpp/gtkmm:3.0` — GTK bindings / GTK привязки
- `gnome-base/librsvg` — SVG rendering / SVG рендеринг
- `media-gfx/imagemagick` — Image conversion / Конвертация изображений
- `dev-libs/glib:2` — GSettings support (optional) / Поддержка GSettings (опционально)
