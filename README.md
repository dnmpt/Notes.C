# Notes.C — Notes Collector

> *Collect, connect, and compose your thoughts — all in one place.*

**Notes.C** (short for *Notes Collector*) is a lightweight desktop application written in **PureBasic** that lets you create, edit, and organize related notes stored in a local **SQLite** database.  
It uses the **Scintilla editing component**, allowing text folding and rich text formatting through Scintilla’s built-in commands.

---

## 🧩 Features

- 🗂️ **Linked Notes** — Organize notes with unique IDs and relationships, stored safely in SQLite.  
- ✍️ **Scintilla-Powered Editor** — Enjoy rich formatting, folding, and syntax-style behavior with lightning-fast performance.  
- 🧠 **Context-Aware Navigation** — Double-click notes to expand related content or view note details dynamically.  
- 💾 **Persistent Storage** — All notes are kept in a single, portable SQLite file — no external dependencies.  
- 🔍 **Search and Filter** — Quickly retrieve notes by ID, title, or content (planned feature).  
- 🌙 **Cross-Platform Ready** — Works on Windows and Linux using native PureBasic and Scintilla libraries.  

---

## 🖥️ Screenshot

<img width="1079" height="616" alt="image" src="https://github.com/user-attachments/assets/5c55ae8f-2107-4f7d-90fb-3e6491e75cc2" />
<br><br>
---

## 🧱 Technical Overview

- **Language:** PureBasic 6.x  
- **Editor Component:** Scintilla (integrated through PureBasic’s ScintillaGadget)  
- **Database Engine:** SQLite (via PureBasic’s built-in database library)  
- **Architecture:** Standalone executable — no runtime required  
- **Interface:** PureBasic GUI with responsive layout and minimalistic controls

---

## ⚙️ How It Works

Each note is stored in an SQLite table, containing:
- **NoteID** — unique identifier  
- **Text** — the Scintilla-formatted text content  
- **Format** — format metadata (bold, italic, etc.)  
- **DateCreated / DateModified** — timestamps  

Notes can reference each other through ID markers (e.g., `[12]`), allowing Notes.C to load or expand related notes dynamically on double-click.

---

## 🪶 Philosophy

> “A simple place for complex ideas.”

Notes.C was designed for professionals, researchers, and creative thinkers who want to keep connected notes *without the noise* of cloud syncs or web distractions.  
Everything stays local, fast, and under your control.

---

## 🪧 License

This project is open source under the **MIT License**:

---

## 🤝 Contributions

Contributions, suggestions, or bug reports are welcome!  
Please open an issue or pull request if you’d like to improve **Notes.C**.

---

### Author

Developed with PureBasic by dnmpt
[https://github.com/dnmpt/Notes.C]

