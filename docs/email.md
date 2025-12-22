# Email (mu4e + offlineimap + BBDB)

This config uses:
- **mu4e** as the email client UI inside Emacs
- **mu** (system package) for indexing/search
- **offlineimap** to sync mail locally into a Maildir
- **smtpmail** to send mail
- **BBDB** for contacts/address book
- **consult-mu** for fast email search

## Keybindings

This config uses `C-c m` as a **Mail** prefix map:
- **Open mu4e**: `C-c m m`
- **Compose new message**: `C-c m M`
- **Open BBDB (contacts)**: `C-c m b`

Consult-mu bindings (when `consult-mu` is installed):
- **Search (default)**: `C-c m s`
- **Dynamic search**: `C-c m d`
- **Async search**: `C-c m a`
- **Search contacts**: `C-c m c`

`consult-mu` is installed by Elpaca from GitHub (see `init.el`). If the commands
aren’t available yet, restart Emacs and/or run `M-x elpaca-process-queues`.

## Required configuration (user-specific)

### 1) Identity (in `custom.el`)

Set these variables in `~/.config/emacs/custom.el`:

```elisp
(setq my/gmail-address "you@gmail.com"
      my/gmail-name "Your Name"
      my/fastmail-address "you@yourdomain.com"
      my/fastmail-name "Your Name")
```

### 2) SMTP passwords (via `pass`)

This config reads SMTP passwords from `pass`:

```bash
pass insert email/gmail
pass insert email/fastmail
```

## System dependencies

### 1) Install `mu` (provides mu4e)

On Arch Linux:

```bash
sudo pacman -S mu
```

After installing, restart Emacs. If mu4e can’t be found, `C-c m m` will show a helpful error message.

### 2) Install and configure `offlineimap`

Your mu4e config expects:
- **Maildir root**: `~/.mail`
- **Sync command**: `offlineimap`

You need to provide your own offlineimap configuration (outside this repo), typically `~/.offlineimaprc`.

## Maildir layout expectations

Contexts in `config/email/email.el` match on Maildir prefix:
- Gmail maildirs under `~/.mail/Gmail/...`
- Fastmail maildirs under `~/.mail/Fastmail/...`

If your sync tool uses different names (e.g. `[Gmail]/Sent Mail` vs `Sent`), adjust the folder vars in `config/email/email.el`.

## Common issues

### “mu4e not found”

- Install `mu` (`sudo pacman -S mu`)
- Restart Emacs
- Confirm `mu` is on PATH: run `mu --version` in a terminal

### “Cannot open load file: bbdb-site”

BBDB’s upstream expects `bbdb-site.el` to exist. This config provides a shim at:
- `config/email/bbdb-site.el`

If you still see the error, it usually means `config/email/` isn’t on `load-path` early enough (it is added in `init.el` in this config).

### “Cannot load consult-mu”

`consult-mu` is installed from source via Elpaca. If it fails to load:
- Restart Emacs and run `M-x elpaca-process-queues`
- Try `M-x elpaca-rebuild` and select `consult-mu`


